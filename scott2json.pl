#!/usr/bin/perl
use strict;
use warnings;
use JSON;
our $VERSION = '1.0.0';
use Readonly;
use Carp;
use English qw( -no_match_vars );
use Getopt::Long;

# ------------------------------------------------------------------------------
Readonly::Scalar my $ACTION_COMMAND_OFFSET    => 6;
Readonly::Scalar my $ACTION_ENTRIES           => 8;
Readonly::Scalar my $AUTO                     => 0;
Readonly::Scalar my $COMMAND_CODE_DIVISOR     => 150;
Readonly::Scalar my $COMMANDS_IN_ACTION       => 4;
Readonly::Scalar my $CONDITION_DIVISOR        => 20;
Readonly::Scalar my $CONDITIONS               => 5;
Readonly::Scalar my $COUNTER_TIME_LIMIT       => 8;
Readonly::Scalar my $DIRECTION_NOUNS          => 6;
Readonly::Scalar my $NORTH                    => 0;
Readonly::Scalar my $SOUTH                    => 1;
Readonly::Scalar my $EAST                     => 2;
Readonly::Scalar my $WEST                     => 3;
Readonly::Scalar my $UP                       => 4;
Readonly::Scalar my $DOWN                     => 5;
Readonly::Scalar my $FALSE                    => 0;
Readonly::Scalar my $FALSE_VALUE              => 0;
Readonly::Scalar my $FLAG_LAMP_EMPTY          => 16;
Readonly::Scalar my $FLAG_NIGHT               => 15;
Readonly::Scalar my $LIGHT_SOURCE_ID          => 9;
Readonly::Scalar my $LIGHT_WARNING_THRESHOLD  => 25;
Readonly::Scalar my $MESSAGE_1_END            => 51;
Readonly::Scalar my $MESSAGE_2_START          => 102;
Readonly::Scalar my $PAR_CONDITION_CODE       => 0;
Readonly::Scalar my $PERCENT_UNITS            => 100;
Readonly::Scalar my $ROOM_INVENTORY           => -1;
Readonly::Scalar my $ROOM_STORE               => 0;
Readonly::Scalar my $ROUNDING_OFFSET          => 0.5;
Readonly::Scalar my $TRUE                     => -1;
Readonly::Scalar my $VERB_CARRY               => 10;
Readonly::Scalar my $VERB_DROP                => 18;
Readonly::Scalar my $VERB_GO                  => 1;
Readonly::Scalar my $VERB_NOUN_DIVISOR        => 150;
Readonly::Scalar my $ALTERNATE_ROOM_REGISTERS => 6;
Readonly::Scalar my $ALTERNATE_COUNTERS       => 9;
Readonly::Scalar my $STATUS_FLAGS             => 32;
Readonly::Scalar my $MINIMUM_COUNTER_VALUE    => -1;
Readonly::Array my @DIRECTION_NOUN_TEXT => qw( NORTH SOUTH EAST WEST UP DOWN );

my $game_file;    # Filename of game data file
my (
    $max_objects_carried, $number_of_actions, $number_of_messages,
    $number_of_objects,   $number_of_rooms,   $number_of_treasures,
    $number_of_words,     $starting_room,     $time_limit,
    $treasure_room_id,    $word_length,       $adventure_version,
    $adventure_number,    $game_bytes,
);

my ( @object_description, @message, @list_of_verbs_and_nouns,
    @room_description );

my ( @action_data, @action_description, @object_original_location,
    @object_location, @room_exit, );

my @condition_code = (
    'parameter',   'carried',   'here',        'present',
    'at',          'not_here',  'not_carried', 'not_at',
    'flag',        'not_flag',  'loaded',      'not_loaded',
    'not_present', 'exists',    'not_exists',  'counter_le',
    'counter_gt',  'not_moved', 'moved',       'counter_eq',
);
my @command_description = (
    'get',            'drop',
    'goto',           'destroy',
    'set_dark',       'clear_dark',
    'set_flag',       'destroy',
    'clear_flag',     'die',
    'put',            'game_over',
    'look',           'score',
    'inventory',      'set_flag0',
    'clear_flag0',    'refill_lamp',
    'clear',          'save_game',
    'swap',           'continue',
    'superget',       'put_with',
    'look',           'dec_counter',
    'print_counter',  'set_counter',
    'swap_room',      'select_counter',
    'add_to_counter', 'subtract_from_counter',
    'print_noun',     'println_noun',
    'println',        'swap_specific_room',
    'pause',
);

# ------------------------------------------------------------------------------

# Load game data file, if specified
if ( !scalar @ARGV ) {
    print STDERR "Please specify a filename as an argument\n";
    exit 1;
}

$game_file = shift @ARGV;
load_game_data_file();

# ------------------------------------------------------------------------------

# Add general header data
my %data_structure;
%{ $data_structure{header} } = (
    game_bytes          => int($game_bytes),
    max_objects_carried => int($max_objects_carried),
    starting_room       => int($starting_room),
    number_of_treasures => int($number_of_treasures),
    word_length         => int($word_length),
    time_limit          => int($time_limit),
    treasure_room_id    => int($treasure_room_id),
    adventure_version   => int($adventure_version),
    adventure_number    => int($adventure_number),
);

# Add actions
for ( my $action_id = 0 ; $action_id < scalar @action_data ; $action_id++ ) {

    # Add title
    $data_structure{action}[$action_id]{title} =
      $action_description[$action_id];

    # Add preconditions
    push @{ $data_structure{action}[$action_id]{precondition} },
      get_action_verb($action_id);
    push @{ $data_structure{action}[$action_id]{precondition} },
      get_action_noun($action_id);

    # Add conditions
    for ( my $condition_id = 1 ;
        $condition_id <= $CONDITIONS ; $condition_id++ )
    {
        push @{ $data_structure{action}[$action_id]{condition} },
          $condition_code[ get_condition_code( $action_id, $condition_id ) ];
        push @{ $data_structure{action}[$action_id]{condition_argument} },
          get_condition_parameter( $action_id, $condition_id );
    }

    # Add commands
    my $command_or_display_message;
    for (
        my $command_id = 0 ;
        $command_id < $COMMANDS_IN_ACTION ;
        $command_id++
      )
    {
        push @{ $data_structure{action}[$action_id]{command} },
          code_for_id( $action_id, $command_id );
    }
}

# Add verbs and nouns
foreach my $vocabulary (@list_of_verbs_and_nouns) {
    Readonly::Scalar my $VERB => 0;
    Readonly::Scalar my $NOUN => 1;
    push @{ $data_structure{verb} }, ${$vocabulary}[$VERB];
    push @{ $data_structure{noun} }, ${$vocabulary}[$NOUN];
}

# Add Rooms
for ( my $room_id = 0 ; $room_id < scalar @room_description ; $room_id++ ) {

    # Clean away the "I'm in a " alias stuff from data
    my $raw_description = $room_description[$room_id];
    if ( $raw_description =~ /\*([\s\S]*)/msx ) {
        $data_structure{room}[$room_id]{description} = $1;
    }
    elsif ( $raw_description =~ /^\W+$/msx ) {
        $data_structure{room}[$room_id]{description} = $raw_description;
    }
    elsif ( length $raw_description > 0 ) {
        $data_structure{room}[$room_id]{description} =
          'I\'m in a ' . $raw_description;
    }
    else {
        $data_structure{room}[$room_id]{description} = $raw_description;
    }
    my $exit_number = $room_exit[$room_id];
    $data_structure{room}[$room_id]{exit} = $exit_number;
}

# Add Messages
for ( my $message_id = 1 ; $message_id < scalar @message ; $message_id++ ) {
    push @{ $data_structure{message} }, $message[$message_id];
}

# Add Objects
for (
    my $object_id = 0 ;
    $object_id < scalar @object_description ;
    $object_id++
  )
{
    my $raw_description = $object_description[$object_id];
    if ( $raw_description =~ /^([^\/]*)\/([^\/]*)\//msx ) {
        $data_structure{object}[$object_id]{description} = $1;
        $data_structure{object}[$object_id]{noun}        = $2;
    }
    else {
        $data_structure{object}[$object_id]{description} = $raw_description;
        $data_structure{object}[$object_id]{noun}        = q{};
    }
    $data_structure{object}[$object_id]{starting_location} =
      int( $object_location[$object_id] );
}

my $json = encode_json \%data_structure;
print "$json\n";

# ------------------------------------------------------------------------------

sub load_game_data_file {
    print STDERR "Processing data file: $game_file\n"
      ;    # Used for debugging broken data files
    open my $handle, '<', $game_file or croak;
    my $file_content = do { local $INPUT_RECORD_SEPARATOR; <$handle> };
    close $handle or croak;
    my $next = $file_content;

    # Define pattern for finding three types of newlines
    my $unix            = qr/(?<![\x0d])[\x0a](?![\x0d])/msx;
    my $apple           = qr/(?<![\x0a])[\x0d](?![\x0a])/msx;
    my $dos             = qr/(?<![\x0d])[\x0d][\x0a](?![\x0a])/msx;
    my $newline_pattern = qr/$unix|$apple|$dos/msx;

    # Replace newline in file with whatever the current system uses
    $file_content =~ s/$newline_pattern/$INPUT_RECORD_SEPARATOR/msxg;

    # extract fields from room entry from data file
    my $room_pattern = qr{
        \s+(-?\d+)
        \s+(-?\d+)
        \s+(-?\d+)
        \s+(-?\d+)
        \s+(-?\d+)
        \s+(-?\d+)
        \s*"([^"]*)"
        (.*)
    }msx;

    # extract fields from object entry
    my $object_pattern = qr{
        \s*\"([^"]*)"
        \s*(-?\d+)
        (.*)
    }msx;

    # extract data from a verb or a noun
    my $word_pattern = qr{
        \s*"([*]?[^"]*?)"
        (.*)
    }msx;

    # extract data from a general text field
    my $text_pattern = qr{
        \s*"([^"]*)"
        (.*)
    }msx;

    # extract a numerical value
    my $number_pattern = qr{
        \s*(-?\d+)
        (.*)
    }msx;

    ( $game_bytes,          $next ) = $next =~ /$number_pattern/msx;
    ( $number_of_objects,   $next ) = $next =~ /$number_pattern/msx;
    ( $number_of_actions,   $next ) = $next =~ /$number_pattern/msx;
    ( $number_of_words,     $next ) = $next =~ /$number_pattern/msx;
    ( $number_of_rooms,     $next ) = $next =~ /$number_pattern/msx;
    ( $max_objects_carried, $next ) = $next =~ /$number_pattern/msx;
    ( $starting_room,       $next ) = $next =~ /$number_pattern/msx;
    ( $number_of_treasures, $next ) = $next =~ /$number_pattern/msx;
    ( $word_length,         $next ) = $next =~ /$number_pattern/msx;
    ( $time_limit,          $next ) = $next =~ /$number_pattern/msx;
    ( $number_of_messages,  $next ) = $next =~ /$number_pattern/msx;
    ( $treasure_room_id,    $next ) = $next =~ /$number_pattern/msx;

    # Actions
    {
        my $action_id = 0;
        while ( $action_id <= $number_of_actions ) {
            my $action_id_entry = 0;
            while ( $action_id_entry < $ACTION_ENTRIES ) {
                ( $action_data[$action_id][$action_id_entry], $next ) =
                  $next =~ /$number_pattern/msx;
                $action_id_entry++;
            }
            $action_id++;
        }
    }

    # Words
    {
        my $word = 0;
        while ( $word < ( ( $number_of_words + 1 ) * 2 ) ) {
            my $input;
            ( $input, $next ) = $next =~ /$word_pattern/msx;
            $list_of_verbs_and_nouns[ int( $word / 2 ) ][ $word % 2 ] = $input;
            $word++;
        }
    }

    # Rooms
    {
        my $room = 0;
        while ( $room <= $number_of_rooms ) {
            (
                $room_exit[$room][$NORTH], $room_exit[$room][$SOUTH],
                $room_exit[$room][$EAST],  $room_exit[$room][$WEST],
                $room_exit[$room][$UP],    $room_exit[$room][$DOWN],
                $room_description[$room],  $next
            ) = $next =~ /$room_pattern/msx;
            foreach ( @{ $room_exit[$room] } ) {
                $_ = int($_);
            }
            $room++;
        }
    }

    # Messages
    {
        my $current_message = 0;
        while ( $current_message <= $number_of_messages ) {
            ( $message[$current_message], $next ) = $next =~ /$text_pattern/msx;
            $current_message++;
        }
    }

    # Objects
    {
        my $object = 0;
        while ( $object <= $number_of_objects ) {
            ( $object_description[$object], $object_location[$object], $next )
              = $next =~ /$object_pattern/msx;
            $object_original_location[$object] = $object_location[$object];
            $object++;
        }
    }

    # Action descriptions
    {
        my $action_counter = 0;
        while ( $action_counter <= $number_of_actions ) {
            ( $action_description[$action_counter], $next ) =
              $next =~ /$text_pattern/msx;
            $action_counter++;
        }
    }

    ( $adventure_version, $next ) =
      $next =~ /$number_pattern/msx;    # Interpreter version
    ( $adventure_number, $next ) =
      $next =~ /$number_pattern/msx;    # Adventure number

    # Replace Ascii 96 with Ascii 34 in output text strings
    foreach ( ( @object_description, @message, @room_description ) ) {
        s/`/"/msxg;
    }

    return 1;
}

sub get_action_verb {
    my $action_id = shift;
    return int( $action_data[$action_id][0] / $VERB_NOUN_DIVISOR );
}

sub get_action_noun {
    my $action_id = shift;
    return $action_data[$action_id][0] % $VERB_NOUN_DIVISOR;
}

sub get_condition_code {
    my $action_id      = shift;
    my $condition      = shift;
    my $condition_raw  = $action_data[$action_id][$condition];
    my $condition_code = $condition_raw % $CONDITION_DIVISOR;
    return $condition_code;
}

sub get_condition_parameter {
    my $action_id           = shift;
    my $condition           = shift;
    my $condition_raw       = $action_data[$action_id][$condition];
    my $condition_parameter = int( $condition_raw / $CONDITION_DIVISOR );
    return $condition_parameter;
}

sub decode_command_from_data {
    my $command_number = shift;
    my $action_id      = shift;
    my $command_code;
    my $merged_command_index =
      int( $command_number / 2 + $ACTION_COMMAND_OFFSET );

    # Even or odd command number?
    if ( $command_number % 2 ) {
        $command_code =
          $action_data[$action_id][$merged_command_index] -
          int( $action_data[$action_id][$merged_command_index] /
              $COMMAND_CODE_DIVISOR ) *
          $COMMAND_CODE_DIVISOR;
    }
    else {

        $command_code = int( $action_data[$action_id][$merged_command_index] /
              $COMMAND_CODE_DIVISOR );
    }
    return $command_code;
}

sub interpret_command {
    my $command_or_display_message = shift;
    my $command_alias;

    # Code above 102? it's printable text!
    if ( $command_or_display_message >= $MESSAGE_2_START ) {
        $command_alias =
          'message_' . ( $command_or_display_message - $MESSAGE_1_END );
    }

    # Do nothing
    elsif ( $command_or_display_message == 0 ) {
        $command_alias = 'no_operation';
    }

    # Code below 52? it's printable text!
    elsif ( $command_or_display_message <= $MESSAGE_1_END ) {
        $command_alias = 'message_' . ( $command_or_display_message - 1 );
    }

    # Code above 52 and below 102? We got some command code to run!
    else {
        my $command_code = $command_or_display_message - $MESSAGE_1_END - 1;
        if ( exists $command_description[$command_code] ) {
            $command_alias = $command_description[$command_code];
        }
        else {
            print STDERR "Undefined command code $command_code. ";
            print STDERR "Setting output code to \"no_operation\".\n";
            $command_alias = 'no_operation';
        }
    }
    return $command_alias;
}

sub code_for_id {
    my $action_id   = shift;
    my $command_id  = shift;
    my $array_index = 6 + int( $command_id / 2 );
    my $command_code;
    if ( ( $command_id % 2 ) == 0 ) {
        $command_code =
          int( $action_data[$action_id][$array_index] / $COMMAND_CODE_DIVISOR );
    }
    else {
        $command_code =
          $action_data[$action_id][$array_index] % $COMMAND_CODE_DIVISOR;
    }
    return interpret_command($command_code);
}
