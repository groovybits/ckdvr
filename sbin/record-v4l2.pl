#!/usr/bin/perl
# record-v4l2.pl created by James A. Pattie <james@pcxperience.com> 04/10/2003
# Copyright 2003
# Purpose: to record from the specified channel for the specified amount
# of time to the video OutputDirectory under the channel-start time name as video.mpg.

#
# You can always get the latest version of this script at
# http://www.pcxperience.org/
#

# 20030425 - 1.4 - Added devfs support based upon patch submitted by
#                  Jonathan Kolb <jkolb-ivtv@greyshift.net>
# 20030426 - 1.5 - Imported the ptune.pl functionality
# 20030426 - 1.6 - moved -F -> -L, -F now lets you specify the frequency to tune to.
# 20030427 - 1.7 - renamed to record_ivtv.pl per Kevin's request.  Added -R option.
# 20030430 - 1.8 - fixing some comparisons that needed to be strings, etc.
# 20030504 - 1.9 - Migrating to Video::ivtv for video resolution support.
# 20030505 - 1.10- Replaced open w/ sysopen but it doesn't make a difference.
#                  Starting to replace the Standard code w/ Video::ivtv methods.
#                  Added the version numbers that I require to the use statements.
# 20030507 - 1.11- Migrated to using get/setFrequency from Video::ivtv 0.03.
# 20030510 - 1.12- Migrated to using get/setInput from Video::ivtv 0.04.  Moved to using
#                  the exported method names rather than Video::ivtv::method().
#                  Converted to using enumerateStandard().
#                  Fixed the condition where switching Video Standards will most likely
#                  not get the correct channel and so would switch back with channel = 0
#                  which is invalid.  In this case I store the previous frequency, do the
#                  channel change but signal to restore the previous frequency on cleanup.
#                  Converted to using enumerateInput().
# 20030512 - 1.13- Added initial support for setting the bitrate/bitrate_peak values.
# 20030513 - 1.14- Tweaked the bitrate values to be closer to real DVD bitrates.
#                  Added support for the .ivtvrc config file and User Profiles.
# 20030516 - 1.15- Updated to the OO interface that Video::ivtv 0.06 now requires.
#                  Cleaned up a lot of the global variables into a settings hash.
#                  Made the -S command add any config items you specified on the command line
#                  that were not in the Profile being updated.  This way you can add new items.
#                  Made the config file work from a mapping hash so that we can easily add/remove
#                  config items in the future.
# 20030518 - 1.16- Fixed a Frequency bug that happened when changing Video Standards and the
#                  Frequency came from a user specified Profile.
# 20030519 - 1.17- Adding the rest of the Codec related options to the config file / defaults.
#                  Switched to using Getopt::Long.  You can specify all config file options at
#                  least by a --long version and still by the original -X command option.
#                  Cleaned up the option parsing code to take advantage of the mappings hash.
# 20030520 - 1.18- Fixing the handling of the Profile command line option.
# 20030524 - 1.19- Cleaned up the output for -L/--list-freqtable.  Changed --list -> --list-freqtable.
#                  Added support to detect the v4l2 driver in use and disable the ivtv "enhancements"
#                  if driver != "ivtv".
#                  Renamed to record-v4l2.pl to reflect the ability of this program to record from any
#                  v4l2 device but with special support for the ivtv driver.
# 20030524 - 1.20- Improving the Ctrl-C handling (cleanup before dying).  It may take a second or two
#                  before the program exits, but it should exit after resetting anything it changed, unless
#                  you had specified not to reset the card.
#                  Allow layering of profiles by calling -P/--profile multiple times.  Each profile will
#                  be layered over the last.  You will not be able to create/update a profile if you
#                  specify more than one though.
#                  Fixed a bug that would cause a parameter from the profile to be set n times, where n was
#                  the number of characters in the mapping string that consisted of the single letter | and
#                  the long command option name.  Ex:  Channel has 'c|channel' so the Channel value was being
#                  set 9 times instead of just the first time if it was in the profile.
# 20030525 - 1.21- Fixed devfsd detection code as it was overriding what came from the config file.
#                  Adding --no-record option so that we can start to implement the replacement functionality for
#                  ptune.pl (ie.  Set all values and then exit, do not reset the card and do not capture)
# 20030607 - 1.22- Adding --directory-format and --date-format options so that the user can specify the
#                  naming convention to use when specifying the directory the output file should be put in.
#                  Tweaked some of the defaults.
#                  Create the config file if it doesn't exist, regardless of the --save flag being specified.
#                  Added method error() to output an error condition that doesn't warrant the whole usage and
#                  converted all relevant usage() calls to error() calls.
#                  Added option --debug to dynamically on the fly enable debug output.
# 20030609 - 1.23- Added option --list-channels to display the currently selected frequency tables contents.
#                  Changed the default output directory to '.'.
#                  Moved $debug -> $settings{Debug} so it can be stored in the config file.  This allows you to
#                  turn debugging on for only certain profiles, etc.
#                  Restructured some of the validity tests to only happen as long as we are recording since they
#                  do not need to be validated when we are not recording.  Mainly to do with the output stuff.
# 20030610 - 1.24- Moved the tunerNum variable into the config file: TunerNum
#                  Added --tuner-num option to dynamically set it.
# 20030614 - 1.25- I now require Video::ivtv 0.09 to make sure everyone is using the version that fixes the known
#                  reported segfault issues.
#                  Added freqtable "custom" support so that people using the new feature in ptune-ui.pl and have
#                  set their default frequency table to be "custom" will just work when they specify channel X, etc.
#                  I'm now sorting the command line input since otherwise I can't guarantee the order options get
#                  processed in, but even that is wrong.  I need to use Tie::IxHash, but that isn't standard.
# 20030626 - 1.26- Updated to cover the audio -> audio_bitmask changes that Video::ivtv 0.11 implemented to cover
#                  the ivtv_ioctl_codec structure changes.
#                  Implemented config file versioning so that I know when the Audio entry needs to be updated in case it
#                  comes back in a future version of the ivtv_ioctl_codec structure.
# 20030628 - 1.27- Adding --list-inputs and --list-standards to display the available inputs and video standards.
# 20030713 - 1.28- Added code to make sure the codec properties are proper when switching standard to PAL/SECAM.
#                  Added config options SetMSPMatrix, MSPInput, MSPOutput, MSPSleep to allow the user to specify if they
#                  want the msp matrix updated any time the Video Standard is changed and to specify what they want programmed.
#                  Bumping the config file version to 2 to account for the new options.
# 20030715 - 1.29- Adding the missing msp matrix reset code in the reset section.
#                  Adding codec checks to make sure that they are right for NTSC.
#                  Made it legal to specify the channel by itself without -c/--channel.
# 20030822 - 1.30- Adding the missing codec value BitrateMode
# 20030927 - 1.31- Adding support to export the settings used as a shell or perl snippet for inclusion
#                  by scripts working with the recorded video files.
#                  Changing the default value of StreamType to 14 since that is near DVD quality.


use strict;
use Getopt::Long qw(:config no_ignore_case bundling);
use Fcntl;
use Video::Frequencies 0.03;
use Video::ivtv 0.12;
use Config::IniFiles;

my $version="1.31";
my $cfgVersion = "2";
my $cfgVersionStr = "_configVersion_";  # hopefully unique [defaults] value to let me know what version the config file is.

my @capabilities = ();  # The cards capabilities

my %settings = (
  Channel           => 4,		# default to the ivtv default channel
  RecordDuration    => 3590,		# default to 59 minutes 50 seconds (in seconds) - This lets 2 back to back cron jobs work!
  InputNum          => 4,      # TV-Tuner 0
  InputName         => "Tuner 0",
  OutputDirectory   => ".",
  VideoDevice       => "/dev/video0",
  VideoWidth        => "720",	# 720x480-fullscreen NTSC
  VideoHeight       => "480",
  VideoStandard     => "NTSC",  # NTSC, PAL or SECAM
  VideoType         => "mpeg",  # mpeg, yuv
  BitrateMode       => 0,       # 0 = VBR, 1 = CBR
  Bitrate           => "6500000",
  PeakBitrate       => "8000000",  # peak bitrate
  Aspect            => 2,
  AudioBitmask      => 0x00e9,
  BFrames           => 3,
  DNRMode           => 0,
  DNRSpatial        => 0,
  DNRTemporal       => 0,
  DNRType           => 0,
  Framerate         => 0,
  FramesPerGOP      => 15,
  GOPClosure        => 1,
  Pulldown          => 0,
  StreamType        => 14,  # 0 = PS, 1 = TS, 2 = MPEG1, 3 = PES_AV, 5 = PES_V, 7 = PES_A, 10 = DVD, 11 = VCD, 12 = SVCD, 13 = DVD-Special 1, 14 = DVD-Special 2
  OutputFileName    => "video.mpg",
  FrequencyTable    => "ntsc-cable",  # default to NTSC_CABLE mapping.
  Frequency         => "", # user specified frequency.
  ResetCardSettings => 1,
  ConfigFileName    => "$ENV{HOME}/.ivtvrc",
  UpdateConfigFile  => 0,
  UseConfigFile     => 0,
  UsingIvtvDriver   => 1,  # default to being able to use the ivtv "enhancements".
  DontRecord        => 0,  # default to always recording data.
  DirectoryFormatString => "%I-%c-%d", # format string used to define the sub directory under OutputDirectory
  DateTimeFormatString  => "+%Y%m%d-%H%M", # format string used to represent the date/time if the user wants it in their DirectoryFormatString
  # define the Codec related min/max values
  minBitrate        => 1,
  maxBitrate        => 14500000,
  minPeakBitrate    => 1150,
  maxPeakBitrate    => 16000000,
  # msp matrix settings
  SetMSPMatrix      => 1,
  MSPInput          => 3,
  MSPOutput         => 1,
  MSPSleep          => 2,  # number of seconds the card needs before we can set the msp matrix.
  # output settings file settings
  OutputSettings     => 1, # bool 0 or 1
  OutputSettingsName => "video.settings",
  OutputSettingsType => "shell", # shell or perl
  # other settings
  Debug             => 0,
  TunerNum          => 0,
);

my $result="";
my @profileNames=(); # list of user defined sections to work with in the config file.
my %configIni;      # config hash we tie to for Config::IniFiles.
my $ivtvObj = Video::ivtv->new();

# map the Settings/Config file parameter to the command line variable that specifies it.
my %mappings = (
    "Channel"           => "c|channel",
    "RecordDuration"    => "t|duration",
    "InputNum"          => "i|inputnum",
    "InputName"         => "I|inputname",
    "OutputDirectory"   => "D|directory",
    "VideoDevice"       => "d|input",
    "VideoWidth"        => "W|width",
    "VideoHeight"       => "H|height",
    "VideoStandard"     => "s|standard",
    "VideoType"         => "T|type",
    "BitrateMode"       => "bitrate-mode",
    "Bitrate"           => "b|bitrate",
    "PeakBitrate"       => "B|peakbitrate",
    "Aspect"            => "aspect",
    "AudioBitmask"      => "audio-bitmask",
    "BFrames"           => "bframes",
    "DNRMode"           => "dnrmode",
    "DNRSpatial"        => "dnrspatial",
    "DNRTemporal"       => "dnrtemporal",
    "DNRType"           => "dnrtype",
    "Framerate"         => "framerate",
    "FramesPerGOP"      => "framespergop",
    "GOPClosure"        => "gopclosure",
    "Pulldown"          => "pulldown",
    "StreamType"        => "streamtype",
    "OutputFileName"    => "o|output",
    "FrequencyTable"    => "f|freqtable",
    "Frequency"         => "F|frequency",
    "ResetCardSettings" => "R|noreset",
    "DirectoryFormatString" => "directory-format",
    "DateTimeFormatString"  => "date-format",
    "Debug"             => "debug",
    "TunerNum"          => "tuner-num",
    "SetMSPMatrix"      => "set-msp-matrix",
    "MSPInput"          => "msp-input",
    "MSPOutput"         => "msp-output",
    "MSPSleep"          => "msp-sleep",
    "OutputSettings"     => "output-settings",
    "OutputSettingsName" => "output-settings-name",
    "OutputSettingsType" => "output-settings-type",
  );

my %codecMappings = (
    "Aspect"       => "aspect",
    "AudioBitmask" => "audio_bitmask",
    "BFrames"      => "bframes",
    "BitrateMode"  => "bitrate_mode",
    "Bitrate"      => "bitrate",
    "PeakBitrate"  => "bitrate_peak",
    "DNRMode"      => "dnr_mode",
    "DNRSpatial"   => "dnr_spatial",
    "DNRTemporal"  => "dnr_temporal",
    "DNRType"      => "dnr_type",
    "Framerate"    => "framerate",
    "FramesPerGOP" => "framespergop",
    "GOPClosure"   => "gop_closure",
    "Pulldown"     => "pulldown",
    "StreamType"   => "stream_type",
  );

# check for devfs support
if ( -e "/dev/.devfsd" )
{
  $settings{VideoDevice} = "/dev/v4l/video0";
}

# check for the config file
if (-f $settings{ConfigFileName})
{
  $settings{UseConfigFile} = 1;

  # tie to it.
  tie %configIni, 'Config::IniFiles', (-file => $settings{ConfigFileName}) or die "Error: Opening config file '$settings{ConfigFileName}' failed! $!\n";

  my $profile = "defaults";
  if (exists $configIni{$profile})
  {
    my $saveFile = 0;
    # check version of the config file.
    if (!exists $configIni{$profile}{$cfgVersionStr})
    {
      print "Updating config file to version 1...\n";

      # first version config file!  Update the Audio -> AudioBitmask entries.
      $configIni{$profile}{$cfgVersionStr} = 1;

      # find all entries that have Audio and move to AudioBitmask.
      foreach my $p (keys %configIni)
      {
        if (exists $configIni{$p}{Audio})
        {
          $configIni{$p}{AudioBitmask} = $configIni{$p}{Audio};
          delete $configIni{$p}{Audio};
        }
      }
      
      $saveFile = 1;  # signal we need to save the config changes.
    }
    if ($configIni{$profile}{$cfgVersionStr} != $cfgVersion)
    {
      # we need to upgrade
      if ($configIni{$profile}{$cfgVersionStr} == 1)
      {
        print "Updating config file to version 2...\n";
        # add the MSP Matrix related options.
        $configIni{$profile}{SetMSPMatrix} = $settings{SetMSPMatrix};
        $configIni{$profile}{MSPInput} = $settings{MSPInput};
        $configIni{$profile}{MSPOutput} = $settings{MSPOutput};
        $configIni{$profile}{MSPSleep} = $settings{MSPSleep};
        $configIni{$profile}{$cfgVersionStr} = 2;
        $saveFile = 1;
      }
    }

    if ($saveFile)
    {
      # now save the updated config file before we continue.
      tied(%configIni)->RewriteConfig or die "Error: Writing config file '$settings{ConfigFileName}' failed!  $!\n";
    }

    # update the defaults stored.
    foreach my $arg (keys %mappings)
    {
      if (exists $configIni{$profile}{$arg})
      {
        $settings{$arg} = $configIni{$profile}{$arg};
        #print "settings{$arg} = '" . $settings{$arg} . "'\n";
      }
    }
  }
  else
  {
    print "Warning: config file '$settings{ConfigFileName}' exists but does not have the\n[$profile] section!  Use -S to create it without specifying -P.\n\n";
  }
}
else  # create the config file
{
  print "Auto Creating config file $settings{ConfigFileName}...\n";
  my $profile = "defaults";

  # we have to create the config file and tie to it.
  tie %configIni, 'Config::IniFiles', () or die "Error: Initializing config file '$settings{ConfigFileName}' failed! $!\n";

  # now set the name to work with.
  tied(%configIni)->SetFileName($settings{ConfigFileName}) or die "Error: Setting config file to '$settings{ConfigFileName}' failed! $!\n";

  $configIni{$profile} = {};  # make sure the section exists.

  foreach my $arg (keys %mappings)
  {
    $configIni{$profile}{$arg} = $settings{$arg};
    print "configIni{$profile}{$arg} = '" . $settings{$arg} . "'\n" if $settings{Debug};
  }

  # set the config file version
  $configIni{$profile}{$cfgVersionStr} = $cfgVersion;

  # write the config file out.
  tied(%configIni)->RewriteConfig or die "Error: Writing config file '$settings{ConfigFileName}' failed!  $!\n";
}

# build up the "custom" frequency table
my %customMap = ();
foreach my $profileName (keys %configIni)
{
  next if $profileName =~ /^(defaults)$/;

  if (exists $configIni{$profileName}{Frequency})
  {
    $customMap{$profileName} = $configIni{$profileName}{Frequency};
  }
}
$CHANLIST{custom} = \%customMap;

# enumerations
my @standards;
my %name2std;
my @inputs;
my %name2input;
my @codecInfo;        # stores the Codec Info
my @newCodecInfo;     # the version we mess with.
# Current settings (Input, Channel, Standard)
my $curinput;
my $curinputName;
my $std;
my $curstd = "???";
my $curStandard = 0;  # numeric representation.
my $curChannel = 0;
my $curFrequency = 0;

my $tuner;
my $settingsFH;  # File Handle for output settings.
my $err;
my $v4l2input;

my $tmpDirectoryStr = formatDirectoryString();
my $versionStr = "record-v4l2.pl $version for use with http://ivtv.sf.net/";
my $usageStr = <<"END_OF_USAGE";
$versionStr

Usage: record-v4l2.pl [--channel CHANNEL] [--duration TIME]
       [--directory DIRECTORY] [--output OUTPUT]
       [--directory-format FORMAT] [--date-format FORMAT]
       [--input VIDEO_DEV][--width WIDTH --height HEIGHT]
       [--standard STANDARD] [--type TYPE]
       [--inputnum INPUT#] [--inputname INPUT NAME]
       [--freqtable FREQENCY MAP] [--frequency FREQUENCY]
       [--bitrate-mode MODE]
       [--bitrate BITRATE] [--peakbitrate PEAK_BITRATE]
       [--set-msp-matrix BOOL] [--msp-sleep SLEEP]
       [--msp-input INPUT] [--msp-output OUTPUT]
       [--profile PROFILE] [--list-freqtable] [--list-channels]
       [--no-record] [--noreset] [--save] [--help] [--version]
       [--aspect ASPECT] [--audio-bitmask AUDIO-BITMASK] [--bframes BFRAMES]
       [--dnrmode DNRMODE] [--dnrspatial DNRSPATIAL]
       [--dnrtemporal DNRTEMPORAL] [--dnrtype DNRTYPE]
       [--framerate FRAMERATE] [--framespergop FRAMESPERGOP]
       [--gopclosure GOPCLOSURE] [--pulldown PULLDOWN]
       [--streamtype STREAMTYPE] [--debug]
       [--tuner-num TUNERNUM] [--output-settings BOOL]
       [--output-settings-name FNAME] [--output-settings-type TYPE]
       [--list-inputs] [--list-standards] [CHANNEL]

  -c/--channel CHANNEL: channel number to switch to
      NOTE: You can also specify the channel by itself.
            Ex.  record-v4l2.pl 73
            would change to channel 73 using the default settings
            or the settings from your ~/.ivtvrc config file.
  -t/--duration TIME: number of seconds to record
  -D/--directory DIRECTORY: Base directory to record into
  --directory-format FORMAT: format string that specifies the
       sub-directory to create under the base directory that
       the output file will be created in.  This can be empty
       to indicate no sub-directory should be created.

       Available tokens are:
         %d - date formatted by --date-format
         %I - input name recorded from
              Any white space in the name is converted to
              underscores (_).  Ex. 'Tuner 0' => 'Tuner_0'

         %c - channel or "freq-#" frequency

  --date-format FORMAT: format string that specifies the
       date format string to generate and substitute for
       %d in the --directory-format string.

       Available tokens:  see the date commands man page.
         The string must start with a + (plus).

  -o/--output OUTPUT: name of file to create
  -d/--input VIDEO_DEV: video device to capture from
  -W/--width WIDTH: width of screen (720 for NTSC fullscreen)
  -H/--height HEIGHT: height of screen (480 for NTSC fullscreen)
  -s/--standard STANDARD: NTSC, PAL or SECAM - video standard to record in
  -T/--type TYPE: mpeg or yuv output
  -i/--inputnum INPUT#:
       The index number of the input you want to use (0 -> n-1)
  -I/--inputname INPUT NAME: The name of the input you want to use.
  -f/--freqtable FREQUENCY MAP: Specify the frequency mapping to use.
  -F/--frequency FREQUENCY: Specify the frequency to tune to.
                ex. 517250 = NTSC Cable 73 (SCiFi)
  --tuner-num TUNERNUM: Specify the tuner to use.
  --set-msp-matrix BOOL: 1 - set the msp matrix after Video Standard changes
                         0 - never set the msp matrix
                         Uses the --msp-input and --msp-output options.
  --msp-sleep SLEEP: number of seconds the card needs before we can program
                     the msp matrix.
  --msp-input INPUT: Specify the input parameter to program the msp matrix.
                     Valid values are from 1 - 8.
  --msp-output OUTPUT: Specify the output parameter to program the msp matrix.
                       Valid values are from 0 - 3.
  -L/--list-freqtable:
       list all available frequency mappings that Video::Frequencies knows
  --list-channels: lists all channels and their frequencies for the
       specified frequency table being used.
  --list-inputs: lists all inputs the v4l2 driver reports.
  --list-standards: lists all Video Standards the v4l2 driver supports.
  -R/--noreset: Do not Reset anything that was changed
      (standard, channel, resolution, etc.)
  --no-record: Do not create any directories, capture data or reset the card
              back to original settings.  This is the ptune.pl mode.
  -h/--help: display this help
  -v/--version: display the version of this program
  --debug: turns on debug output
  --output-settings BOOL: Turns on or off the creation of the settings
                          file that contains perl or shell variables that
                          represent the settings used to record the video file.
                          This feature is ignored if --no-record specified.
  --output-settings-name FNAME: The name of the file to write the settings to.
                                It must end in .settings.
  --output-settings-type TYPE: Either 'shell' or 'perl'.
            If 'shell', then all variables output are prefixed with REC_
            and are upper cased.  Ex: StreamType => REC_STREAMTYPE="14"
            If 'perl', then all variables output are created in the
            %settings hash.  Ex: StreamType => $settings{StreamType} = "14";

  Codec related options:
  --bitrate-mode MODE: 0 = VBR, 1 = CBR
  -b/--bitrate BITRATE: Specify the Bitrate to capture at in Mbps
  -B/--peakbitrate PEAK_BITRATE: Specify the Peak Bitrate to capture at in Mbps
  --aspect ASPECT: Specify the aspect ratio
  --audio-bitmask AUDIO-BITMASK:  Specify the audio bitmask value
  --bframes BFRAMES: Specify the number of B frames value
  --dnrmode DNRMODE: Specify the dnr_mode value
  --dnrspatial DNRSPATIAL: Specify the dnr_spatial value
  --dnrtemporal DNRTEMPORAL: Specify the dnr_temporal value
  --dnrtype DNRTYPE: Specify the dnr_type value
  --framerate FRAMERATE: Specify the framerate value. 0 = 30fps, 1 = 25fps
  --framespergop FRAMESPERGOP: Specify the GOP size
  --gopclosure GOPCLOSURE: Specify if you want open/closed GOP's.
  --pulldown PULLDOWN: 1 = Inverse telecine on, 0 = off
  --streamtype STREAMTYPE: Specify the stream_type value
      Valid Values are:
        0 - PS
        1 - TS
        2 - MPEG1
        3 - PES_AV
        5 - PES_V
        7 - PES_A
       10 - DVD
       11 - VCD
       12 - SVCD
       13 - DVD-Special 1
       14 - DVD-Special 2

  Config file related options:
  -P/--profile PROFILE: Override defaults and command line values with the
              config entries in the section labeled [PROFILE] from the
              config file $settings{ConfigFileName}.
              Examples: -P NTSC-DVD, -P PAL-DVD, --profile MY-SETTINGS

              You can specify this option multiple times and each successive
              profile will overlay the defaults and any previous profiles.
              You will not be able to create/update a profile if you do
              specify multiple profiles.
  -S/--save: save the current values as the defaults in
      $settings{ConfigFileName}.
      If -P/--profile PROFILE is specified, then those values that exist in
      the specified profile will be updated.  If the profile doesn't exist,
      then it will be created, but will have all possible config items
      defined in it.  It will be your responsibility to hand check the
      config file and remove any config items you do not want set for
      that profile.
      Any options specified on the command line will override options
      defined in the config file.

Notes:
  If you specify both -i/--inputnum and -I/--inputname then
      -i/--inputnum will take precedence.

  If you specify both -c/--channel and -F/--frequency then
      -F/--frequency will take precedence.

  If you use a Profile, it has the ability to override all command line
    arguments, so check your Profile first if things seem to be ignored.

Defaults:
 --duration $settings{RecordDuration} --input $settings{VideoDevice} --width $settings{VideoWidth} --height $settings{VideoHeight} --standard $settings{VideoStandard}
 --type $settings{VideoType} --directory $settings{OutputDirectory} --output $settings{OutputFileName}
 --directory-format "$settings{DirectoryFormatString}" --date-format "$settings{DateTimeFormatString}"
 --inputnum $settings{InputNum} --inputname '$settings{InputName}' --freqtable $settings{FrequencyTable}
 --set-msp-matrix $settings{SetMSPMatrix} --msp-sleep $settings{MSPSleep} --msp-input $settings{MSPInput} --msp-output $settings{MSPOutput}
 --bitrate $settings{Bitrate} --peakbitrate $settings{PeakBitrate} --aspect $settings{Aspect} --audio-bitmask $settings{AudioBitmask} --bframes $settings{BFrames}
 --dnrmode $settings{DNRMode} --dnrspatial $settings{DNRSpatial} --dnrtemporal $settings{DNRTemporal} --dnrtype $settings{DNRType}
 --framerate $settings{Framerate} --framespergop $settings{FramesPerGOP} --gopclosure $settings{GOPClosure} --pulldown $settings{Pulldown} --streamtype $settings{StreamType}
 --tuner-num $settings{TunerNum} --output-settings $settings{OutputSettings} --output-settings-name $settings{OutputSettingsName} --output-settings-type $settings{OutputSettingsType}

 config file = '$settings{ConfigFileName}'

 If Channel = $settings{Channel}, this would create:
 $tmpDirectoryStr$settings{OutputFileName}

 Note:  This script relies on Perl Modules: Video::Frequencies, Video::ivtv,
 Config::IniFiles and Getopt::Long.
END_OF_USAGE

# handle user input here
my %opts;
#getopts('c:t:o:hd:W:H:s:T:D:vi:I:f:F:LRb:B:P:S', \%opts);
GetOptions(\%opts, "channel|c=s", "duration|t=i", "output|o=s", "help|h", "input|d=s", "width|W=i", "height|H=i", "standard|s=s",
                   "type|T=s", "directory|D=s", "version|v", "inputnum|i=i", "inputname|I=s", "freqtable|f=s", "frequency|F=i", "list-freqtable|L",
                   "noreset|R", "bitrate|b=i", "peakbitrate|B=i", "profile|P=s@", "save|S", "aspect=i", "audio-bitmask=s", "bframes=i", "dnrmode=i", "dnrspatial=i",
                   "dnrtemporal=i", "dnrtype=i", "framerate=i", "framespergop=i", "gopclosure=i", "pulldown=i",
                   "streamtype=i", "no-record", "directory-format=s", "date-format=s", "debug", "list-channels",
                   "tuner-num=i", "list-inputs", "list-standards", "set-msp-matrix=i", "msp-input=i", "msp-output=i",
                   "bitrate-mode=i", "output-settings=i", "output-settings-name=s", "output-settings-type=s");
if (scalar keys %opts == 0 && @ARGV == 0)
{
  usage(0, "");
}
foreach my $option (sort keys %opts)
{
  my $found = 0;
  foreach my $mapName (keys %mappings)
  {
    if ($option =~ /^($mappings{$mapName})$/)
    {
      $settings{$mapName} = $opts{$option};
      $found = 1;
      print "$mapName = '$opts{$option}'\n" if $settings{Debug};
    }
  }
  if (!$found)
  {
    # handle the non-settings cases.
    if ($option =~ /^(L|list-freqtable)$/)
    {
      my $errStr = "\nAvailable Frequency Mappings:\n";
      foreach my $name (sort keys %CHANLIST)
      {
        $errStr .= "$name\n";
      }
      print "$versionStr\n$errStr";
      exit 0;
    }
    elsif ($option eq "list-channels")
    {
      my $errStr = "\nAvailable Channels for $settings{FrequencyTable}:\n";
      foreach my $name (sort { $a <=> $b } keys %{$CHANLIST{$settings{FrequencyTable}}})
      {
        $errStr .= "$name\t= $CHANLIST{$settings{FrequencyTable}}->{$name}\n";
      }
      print "$versionStr\n$errStr";
      exit 0;
    }
    elsif ($option =~ /^(no-record)$/)
    {
      $settings{DontRecord} = 1;
    }
    elsif ($option =~ /^(S|save)$/)
    {
      $settings{UpdateConfigFile} = 1;
    }
    elsif ($option =~ /^(P|profile)$/)
    {
      @profileNames = @{$opts{$option}};
    }
    elsif ($option =~ /^(v|version)$/)
    {
      print "$versionStr\n";
      exit 0;
    }
    elsif ($option =~ /^(h|help)$/)
    {
      usage(0, "");
    }
    elsif ($option =~ /^(list-inputs|list-standards)$/)
    {
      # do nothing for now since they will be handled later.
    }
    else
    {
      usage(1, "-$option is an unknown option!");
    }
  }
}

if (@profileNames)
{
  # loop over all profiles the user specified.
  foreach my $profileName (@profileNames)
  {
    print "profile = '$profileName'\n" if $settings{Debug};
    # for now the profile can not be "defaults".
    if ($profileName eq "defaults")
    {
      error(1, "Profile = '$profileName' is invalid!");
    }
    if (exists $configIni{$profileName})
    {
      # update defaults/override command line arguments that exist in this profile.
      my $profileUpdating = (((exists $opts{S} || exists $opts{save}) && @profileNames == 1) ? 1 : 0);
      my $profile = $profileName;

      foreach my $arg (keys %mappings)
      {
        foreach my $option (split(/\|/, $mappings{$arg})) # handle the long/short command option versions
        {
          #print "arg = '$arg', option = '$option'\n" if $settings{Debug};
          if (exists $configIni{$profile}{$arg} && !($profileUpdating && exists $opts{$option}))
          {
            $settings{$arg} = $configIni{$profile}{$arg};
            print "settings{$arg} = '" . $settings{$arg} . "'\n" if $settings{Debug};
            last;
          }
        }
      }
    }
    else
    {
      if ($settings{UpdateConfigFile} && @profileNames == 1)
      {
        print "Warning:  Profile = '$profileName' will be created.\n" if ($settings{Debug});
      }
      else
      {
        error(1, "Profile = '$profileName' does not exist! You must specify -S/--save to create it.");
      }
    }
  }
}

# verify input

if (@ARGV)
{
  if (exists $opts{c} || exists $opts{channel})
  {
    print "Warning: ignoring channel argument and using '$ARGV[0]' instead.\n";
  }
  $settings{Channel} = $ARGV[0];
}

my $directoryName;
if (!$settings{DontRecord})
{
  print "RecordDuration = $settings{RecordDuration}\n" if $settings{Debug};

  if ($settings{VideoType} !~ /^(mpeg|yuv)$/)
  {
    error(1, "Video Type = '$settings{VideoType}' is invalid!");
  }
  if ($settings{VideoType} eq "yuv")
  {
    # see if we need to change our defaults.
    if (!exists $opts{o} && !exists $opts{output})
    {
      $settings{OutputFileName} = "video.yuv";
    }
    if (!exists $opts{d} && !exists $opts{input})
    {
      if ( -e "/dev/.devfsd" )
      {
        $settings{VideoDevice} = "/dev/v4l/yuv0";
      }
      else
      {
        $settings{VideoDevice} = "/dev/yuv0";
      }
    }
  }

  if ( ! -d "$settings{OutputDirectory}")
  {
    error(1, "Directory = '$settings{OutputDirectory}' is invalid!  $!");
  }
  # make directory
  $directoryName = formatDirectoryString();
  $result=`mkdir -p $directoryName`;
}

# verify the output-settings options
if ($settings{OutputSettings} !~ /^[01]$/)
{
  error(1, "OutputSettings = '$settings{OutputSettings}' is invalid!");
}
if ($settings{OutputSettings} && $settings{DontRecord})
{
  $settings{OutputSettings} = 0;  # turn off feature since we are not recording.
}
if ($settings{OutputSettings})
{
  if ($settings{OutputSettingsName} !~ /^(.+\.settings)$/)
  {
    error(1, "OutputSettingsName = '$settings{OutputSettingsName}' is invalid!  It must end in .settings.");
  }
  if ($settings{OutputSettingsType} !~ /^(shell|perl)$/)
  {
    error(1, "OutputSettingsType = '$settings{OutputSettingsType}' is invalid!  It must be either 'shell' or 'perl'.");
  }
  sysopen($settingsFH, "$directoryName/$settings{OutputSettingsName}", O_CREAT | O_WRONLY) or die "Error creating file '$settings{OutputSettingsName}': $!\n";
  outputSettingSetup();
}

if ( ! -c "$settings{VideoDevice}")
{
  error(1, "Video Dev = '$settings{VideoDevice}' is invalid!  $!");
}

# now that the video device has been semi validated, we can use it to lookup
# the inputs, standards, etc. and use that for validating some of the following
# pieces of user input.
sysopen($tuner, $settings{VideoDevice}, O_RDWR) or die "Error unable to open '$settings{VideoDevice}': $!";
my $tunerFD = fileno($tuner);

outputSetting("VideoDevice");

# get the current capabilities.
@capabilities = $ivtvObj->getCapabilities($tunerFD);
if (@capabilities != keys %{$ivtvObj->{capIndexes}})
{
  error(1, "getCapabilities() failed!");
}
if ($capabilities[$ivtvObj->{capIndexes}{driver}] ne "ivtv")
{
  $settings{UsingIvtvDriver} = 0;  # we can't use the ivtv "enhancements".
  print "Warning:  V4l2 driver = '$capabilities[$ivtvObj->{capIndexes}{driver}]' does not support the ivtv \"enhancements\"!\n";
  print "          All codec related options will be ignored.\n\n";
}

my $i;

# get the current video standard
$std = $ivtvObj->getStandard($tunerFD);
if ($std > 0)
{
  printf("Standard: 0x%08x\n",$std) if ($settings{Debug});
}
else
{
  die "Error: getStandard() failed!\n";
}

# get the current input
$curinput = $ivtvObj->getInput($tunerFD);
if ($curinput < 0)
{
  die "Error: getInput() failed!\n";
}
printf("Input: 0x%08x\n",$curinput) if ($settings{Debug});

my $done=0;
# Standards
for ($i=0; !$done; ++$i)
{
  my($index,$std_id,$name,$frameperiod_n,$frameperiod_d,$framelines) = $ivtvObj->enumerateStandard($tunerFD, $i);
  if ($index == -1)
  {
    $done = 1;
  }
  else
  {
    printf("%d 0x%08x %s %d/%d %d\n",$index,$std_id,$name,$frameperiod_n,$frameperiod_d,$framelines) if ($settings{Debug});
    push @standards, [($name,$std_id)];
    $name2std{$name} = $std_id;
    if( (($std_id & $std) == $std))
    {
      $curstd = $name;
      $curStandard = $std;
    }
  }
}

if (exists $opts{'list-standards'})
{
  print "$versionStr\n";
  print "Available Video Standards:\n";
  foreach my $standard (@standards)
  {
    print "$standard->[0]\n";
  }
  exit 0;
}

$done=0;
# Inputs
for ($i=0; !$done; ++$i)
{
  my($index,$name,$type,$audioset,$tuner,$std,$status) = $ivtvObj->enumerateInput($tunerFD, $i);
  if ($index == -1)
  {
    $done = 1;
  }
  else
  {
    push @inputs, $name;
    $name2input{$name} = $index;
  }
}
$curinputName = $inputs[$curinput];

if (exists $opts{'list-inputs'})
{
  print "$versionStr\n";
  print "Available Inputs:\n";
  my $counter = 0;
  foreach my $input (@inputs)
  {
    print "$counter: $input\n";
    $counter++;
  }
  exit 0;
}

if ($settings{UsingIvtvDriver})
{
  # get the current Codec Info
  @codecInfo = $ivtvObj->getCodecInfo($tunerFD);
  if (@codecInfo != keys %{$ivtvObj->{codecIndexes}})
  {
    error(1, "getCodecInfo() failed!");
  }
  @newCodecInfo = $ivtvObj->getCodecInfo($tunerFD);
  if (@newCodecInfo != keys %{$ivtvObj->{codecIndexes}})
  {
    error(1, "getCodecInfo() failed!");
  }
}

# finish validating the user input.

if (!$settings{DontRecord})
{
  if ($settings{RecordDuration} !~ /^(\d+)$/)
  {
    error(1, "Time = '$settings{RecordDuration}' is invalid!");
  }

  outputSetting("RecordDuration");
  outputSetting("OutputDirectory");

  # assume for now we are only generating mpeg files.
  if (($settings{VideoType} eq "mpeg" && $settings{OutputFileName} !~ /^.+\.mpg$/) || ($settings{VideoType} eq "yuv" && $settings{OutputFileName} !~ /^.+\.yuv$/))
  {
    error(1, "Output = '$settings{OutputFileName}' is invalid!");
  }

  outputSetting("VideoType");
  outputSetting("OutputFileName");

  if ($settings{DateTimeFormatString} !~ /^(\+((\%.)|.)+)$/)
  {
    usage(1, "Date Format String = '$settings{DateTimeFormatString}' is invalid!");
  }

  outputSetting("DateTimeFormatString");
}

if ($settings{VideoWidth} !~ /^(\d+)$/)
{
  error(1, "Width = '$settings{VideoWidth}' is invalid!");
}

outputSetting("VideoWidth");

if ($settings{VideoHeight} !~ /^(\d+)$/)
{
  error(1, "Height = '$settings{VideoHeight}' is invalid!");
}

outputSetting("VideoHeight");

if (!exists $name2std{$settings{VideoStandard}})
{
  my $validStandards = join(", ", keys(%name2std));
  error(1, "Video Standard = '$settings{VideoStandard}' is invalid!\nValid Standards are: $validStandards");
}

outputSetting("VideoStandard");

if (exists $opts{i} || exists $opts{inputnum})
{
  if ($settings{InputNum} < 0 || $settings{InputNum} >= scalar(@inputs))
  {
    error(1, "Video Input = '$settings{InputNum}' is invalid!\nValid Inputs are from 0 - " . int(scalar(@inputs) - 1));
  }
  $settings{InputName} = $inputs[$settings{InputNum}];
}

outputSetting("InputName");

if ((exists $opts{I} || exists $opts{inputname}) && !(exists $opts{i} || exists $opts{inputnum}))
{
  if (!exists $name2input{$settings{InputName}})
  {
    my $validInputs = join(", ", @inputs);
    error(1, "Video Input Name = '$settings{InputName}' is invalid!\nValid Input Names are: $validInputs");
  }
  $settings{InputNum} = $name2input{$settings{InputName}};
}

outputSetting("InputNum");

if (!exists $CHANLIST{$settings{FrequencyTable}})
{
  error(1, "Frequency Table = '$settings{FrequencyTable}' is invalid!");
}

outputSetting("FrequencyTable");

# only validate the channel if the input is a tuner.
if ($inputs[$settings{InputNum}] =~ /Tuner/)
{
  if ($settings{TunerNum} !~ /^(\d)$/)
  {
    error(1, "TunerNum = '$settings{TunerNum}' is invalid!");
  }
  if (exists $opts{F} || exists $opts{frequency} || $settings{Frequency}) # the user may have specified a Frequency in their config file
  {
    if ($settings{Frequency} !~ /^(\d+)$/)
    {
      error(1, "Frequency = '$settings{Frequency}' is invalid!");
    }
    $settings{Channel} = "freq-$settings{Frequency}";  # make sure we output the channel part.
  }
  # now verify that the channel exists in the frequency table!
  else
  {
    if (!$settings{Channel})
    {
      error(1, "channel = '$settings{Channel}' is invalid!");
    }
    # first verify the freqency table is appropriate for the standard (NTSC, PAL, SECAM),
    # unless they specified the frequency to tune to.
    if ($settings{FrequencyTable} !~ /^(custom|$settings{VideoStandard})/i)
    {
      error(1, "You specified Video Standard '$settings{VideoStandard}' which is incompatible with Frequency Table '$settings{FrequencyTable}'!");
    }
    if (!exists $CHANLIST{$settings{FrequencyTable}}->{$settings{Channel}})
    {
      error(1, "Channel = '$settings{Channel}' does not exist in Frequency Table '$settings{FrequencyTable}'!");
    }
  }

  outputSetting("Channel");
  outputSetting("Frequency");

  # get the current channel/frequency value.
  my $Frequency;
  if(($Frequency = $ivtvObj->getFrequency($tunerFD, $settings{TunerNum})) >= 0)
  {
    my $freq = ($Frequency * 1000) / 16;
    print "freq = $freq\n" if ($settings{Debug});
    # find the associated channel.
    if ((!exists $opts{F} && !exists $opts{frequency} && !$settings{Frequency}) && ($curstd eq $settings{VideoStandard}) )
    {
      foreach my $chan (keys %{$CHANLIST{$settings{FrequencyTable}}})
      {
        if ($CHANLIST{$settings{FrequencyTable}}->{$chan} == $freq)
        {
          $curChannel = $chan;
        }
      }
      print "curChannel = $curChannel\n" if ($settings{Debug});
    }
    else
    {
      $curFrequency = $freq;
    }
  }
  else
  {
    die "Error: getFrequency() failed!\n";
  }
}
else
{
  # set the channel = "" so we know to ignore it.
  $settings{Channel} = "";
}

if ($settings{UsingIvtvDriver})
{
  # validate the Codec related stuff.
  if ($settings{BitrateMode} !~ /^(0|1)$/)
  {
    error(1, "BitrateMode = '$settings{BitrateMode}' is invalid!");
  }
  if ($settings{Bitrate} < $settings{minBitrate} || $settings{Bitrate} > $settings{maxBitrate})
  {
    error(1, "Bitrate = '$settings{Bitrate}' is invalid!");
  }
  if ($settings{PeakBitrate} < $settings{Bitrate})
  {
    error(1, "PeakBitrate can not be less than Bitrate!");
  }
  elsif ($settings{PeakBitrate} == $settings{Bitrate} && !$settings{BitrateMode} == 1)
  {
    error(1, "PeakBitrate can not be equal to Bitrate in VBR Mode!");
  }
  elsif ($settings{PeakBitrate} < $settings{minPeakBitrate} || $settings{PeakBitrate} > $settings{maxPeakBitrate})
  {
    error(1, "PeakBitrate = '$settings{PeakBitrate}' is invalid!");
  }

  if ($settings{VideoStandard} !~ /^(NTSC)/)
  {
    my $warn = 0;
    if ($settings{Framerate} == 0)
    {
      $settings{Framerate} = 1;
      $warn = 1;
    }
    if ($settings{FramesPerGOP} == 15)
    {
      $settings{FramesPerGOP} = 12;
      $warn = 1;
    }
    if ($warn)
    {
      print "Warning:  Setting Framerate/FramesPerGOP to PAL settings for Video Standard '$settings{VideoStandard}'!\n\nYou should either specify on the command line or in the ~/.ivtvrc config file.\n";
    }
  }
  elsif ($settings{VideoStandard} =~ /^(NTSC)/)
  {
    my $warn = 0;
    if ($settings{Framerate} == 1)
    {
      $settings{Framerate} = 0;
      $warn = 1;
    }
    if ($settings{FramesPerGOP} == 12)
    {
      $settings{FramesPerGOP} = 15;
      $warn = 1;
    }
    if ($warn)
    {
      print "Warning:  Setting Framerate/FramesPerGOP to NTSC settings for Video Standard '$settings{VideoStandard}'!\n\nYou should either specify on the command line or in the ~/.ivtvrc config file.\n";
    }
  }

  if ($settings{SetMSPMatrix} !~ /^(0|1)$/)
  {
    error(1, "SetMSPMatrix = '$settings{SetMSPMatrix}' is invalid!  It can only be 0 or 1.");
  }
  if ($settings{MSPInput} < 1 || $settings{MSPInput} > 8)
  {
    error(1, "MSPInput = '$settings{MSPInput}' is invalid!  It can only be 1 - 8.");
  }
  if ($settings{MSPOutput} < 0 || $settings{MSPOutput} > 3)
  {
    error(1, "MSPOutput = '$settings{MSPOutput}' is invalid!  It can only be 0 - 3.");
  }
  
  if ($settings{StreamType} < 0 || $settings{StreamType} > 14)
  {
    error(1, "StreamType = '$settings{StreamType}' is invalid!");
  }

  outputSetting("BitrateMode");
  outputSetting("Bitrate");
  outputSetting("PeakBitrate");
  outputSetting("SetMSPMatrix");
  outputSetting("MSPInput");
  outputSetting("MSPOutput");
  outputSetting("Framerate");
  outputSetting("FramesPerGOP");
  outputSetting("Aspect");
  outputSetting("AudioBitmask");
  outputSetting("BFrames");
  outputSetting("DNRMode");
  outputSetting("DNRSpatial");
  outputSetting("DNRTemporal");
  outputSetting("DNRType");
  outputSetting("GOPClosure");
  outputSetting("Pulldown");
  outputSetting("StreamType");
}

# update the config file if the user wants us to.
if ($settings{UpdateConfigFile})
{
  my $profile;
  if (@profileNames > 1)
  {
    print "Warning:  Not updating config file as you have more than 1 profile specified!\n";
  }
  elsif (@profileNames == 1)
  {
    $profile = $profileNames[0];
  }
  else
  {
    $profile = "defaults";
  }
  if ($profile)
  {
    my $createProfile = (exists $configIni{$profile} ? 0 : 1);
    print "Creating Profile = '$profile': $createProfile\n" if ($settings{Debug});

    if (!$settings{UseConfigFile})
    {
      # we have to create the config file and tie to it.
      tie %configIni, 'Config::IniFiles', () or die "Error: Initializing config file '$settings{ConfigFileName}' failed! $!\n";

      # now set the name to work with.
      tied(%configIni)->SetFileName($settings{ConfigFileName}) or die "Error: Setting config file to '$settings{ConfigFileName}' failed! $!\n";

      $configIni{$profile} = {};  # make sure the section exists.
    }

    foreach my $arg (keys %mappings)
    {
      foreach my $option (split(/\|/, $mappings{$arg})) # handle the long/short command option versions
      {
        if (exists $configIni{$profile}{$arg} || $createProfile || exists $opts{$option})
        {
          $configIni{$profile}{$arg} = $settings{$arg};
          print "configIni{$profile}{$arg} = '" . $settings{$arg} . "'\n" if $settings{Debug};
          last;
        }
      }
    }

    # write the config file out.
    tied(%configIni)->RewriteConfig or die "Error: Writing config file '$settings{ConfigFileName}' failed!  $!\n";
  }
}

# this hash keeps track of those values I have to set back.
my %changedSettings = (
    resolution => 0,
    standard => 0,
    VideoType => 0,
    InputNum => 0,
    Channel => 0,
    Frequency => 0,
    codec => 0,
    );

# change the channel
if ($inputs[$settings{InputNum}] =~ /Tuner/)
{
  if (exists $opts{F} || exists $opts{frequency} || $settings{Frequency})
  {
    if ($settings{Frequency} != $curFrequency)
    {
      $changedSettings{Frequency} = 1;
      tuneFrequency($settings{Frequency});
    }
  }
  else
  {
    if ($curstd ne $settings{VideoStandard})
    {
      # we have to set the channel regardless.
      # but we want to tune back to the previous frequency.
      $changedSettings{Frequency} = 1;
      changeChannel($settings{Channel});
    }
    elsif ($settings{Channel} ne $curChannel)
    {
      # otherwise we just changeChannel and restore the previous channel.
      $changedSettings{Channel} = 1;
      changeChannel($settings{Channel});
    }
  }
}

# set the video standard
if ($settings{VideoStandard} ne $curstd)
{
  $changedSettings{standard} = 1;
  change_standard();

  # see if we have to re-program the msp matrix
  if ($settings{UsingIvtvDriver})
  {
    if ($settings{SetMSPMatrix})
    {
      print "Setting msp matrix: input = $settings{MSPInput}, output = $settings{MSPOutput}\n" if $settings{Debug};
      sleep ($settings{MSPSleep});  # sleep for 2 seconds to let card settle down.
      $result = $ivtvObj->mspMatrixSet($tunerFD, $settings{MSPInput}, $settings{MSPOutput});
      if (not defined $result)
      {
        die "Error calling mspMatrixSet!\n";
      }
      if (!$result)
      {
        die "Error in mspMatrixSet ioctl call!\n";
      }
    }
  }
}

# set the input
if ($settings{InputNum} != $curinput || $settings{InputName} ne $curinputName)
{
  $changedSettings{InputNum} = 1;
  if (!(exists $opts{i} || exists $opts{inputnum} || exists $opts{I} || exists $opts{inputname}))  # our defaults are different than the current values!
  {
    print "Warning:  Changing input from $curinputName to $settings{InputName}\n";
  }
  change_input();
}

# set the capture type

# store the current width,height so we can restore afterwards
my ($oldWidth, $oldHeight) = $ivtvObj->getResolution($tunerFD);
print "oldWidth = '$oldWidth', oldHeight = '$oldHeight'\n" if ($settings{Debug});

if ($settings{VideoWidth} != $oldWidth || $settings{VideoHeight} != $oldHeight)
{
  $changedSettings{resolution} = 1;
}

# specify the width,height to capture
if ($changedSettings{resolution})
{
  $result = $ivtvObj->setResolution($tunerFD, $settings{VideoWidth}, $settings{VideoHeight});
  if (not defined $result)
  {
    die "Error calling setResolution!\n";
  }
  if (!$result)
  {
    die "Error in setResolution ioctl call!\n";
  }
}

if ($settings{UsingIvtvDriver})
{
  # specify the codec options to capture mpeg's at.
  foreach my $codecName (keys %codecMappings)
  {
    my $codecIndex = $ivtvObj->{codecIndexes}{$codecMappings{$codecName}};
    if ($codecInfo[$codecIndex] != $settings{$codecName})
    {
      $changedSettings{codec} = 1;
      $newCodecInfo[$codecIndex] = $settings{$codecName};
      print "new $codecName = '$settings{$codecName}', old $codecName = '$codecInfo[$codecIndex]'\n" if $settings{Debug};
    }
  }
}

if ($changedSettings{codec})
{
  $result = $ivtvObj->setCodecInfo($tunerFD, @newCodecInfo);
  if (!$result)
  {
    die "Error calling setCodecInfo()!\n";
  }
}

if (!$settings{DontRecord})
{
  close($settingsFH) if ($settings{OutputSettings});

  # capture the video/audio to video.mpg
  captureVideo(directoryName => $directoryName, RecordDuration => $settings{RecordDuration},
              OutputFileName => $settings{OutputFileName}, tuner => $tuner);
}

if ($settings{ResetCardSettings} && !$settings{DontRecord})
{
  # restore Codec values
  if ($changedSettings{codec})
  {
    $result = $ivtvObj->setCodecInfo($tunerFD, @codecInfo);
    if (!$result)
    {
      die "Error calling setCodecInfo()!\n";
    }
  }

  # restore the previous width,height settings
  if ($changedSettings{resolution})
  {
    $result = $ivtvObj->setResolution($tunerFD, $oldWidth, $oldHeight);
    if (not defined $result)
    {
      die "Error calling setResolution!\n";
    }
    if (!$result)
    {
      die "Error in setResolution ioctl call!\n";
    }
  }

  # restore the previous input setting
  if ($changedSettings{InputNum})
  {
    # reset back to the old input name
    $settings{InputName} = $curinputName;
    change_input();
  }

  # restore the previous video standard
  if ($changedSettings{standard})
  {
    $settings{VideoStandard} = $curstd;
    change_standard();

    # see if we have to re-program the msp matrix
    if ($settings{UsingIvtvDriver})
    {
      if ($settings{SetMSPMatrix})
      {
        print "Setting msp matrix: input = $settings{MSPInput}, output = $settings{MSPOutput}\n" if $settings{Debug};
        sleep ($settings{MSPSleep});  # sleep for 2 seconds to let card settle down.
        $result = $ivtvObj->mspMatrixSet($tunerFD, $settings{MSPInput}, $settings{MSPOutput});
        if (not defined $result)
        {
          die "Error calling mspMatrixSet!\n";
        }
        if (!$result)
        {
          die "Error in mspMatrixSet ioctl call!\n";
        }
      }
    }
  }

  # restore the previous channel
  if ($changedSettings{Channel})
  {
    changeChannel($curChannel);
  }
  if ($changedSettings{Frequency})
  {
    tuneFrequency($curFrequency);
  }
}

# close the tuner device
close($tuner);

exit 0;

# usage(returnValue, ErrorString)
# returnValue = 1 or 0
# ErrorString = message you want to tell the user, but only if returnValue = 1.
sub usage
{
  my $errorCode = shift;
  my $error = shift;

  print $usageStr;
  print "\nError:  $error\n" if ($errorCode == 1);
  print "$error\n" if ($errorCode == 2);

  exit $errorCode;
}

# error(returnValue, ErrorString)
# returnValue = 1 or 0
# ErrorString = message you want to tell the user.
sub error
{
  my $errorCode = shift;
  my $error = shift;

  print "$versionStr";
  print "\nError:  $error\n";

  exit $errorCode;
}

# changes the input to $settings{InputNum} as long as it isn't = $curinput
sub change_input {
  my $preinput = $name2input{$settings{InputName}};
  if($preinput != $curinput)
  {
    $curinput = $preinput;
    print "input now $settings{InputName}, #$preinput\n" if ($settings{Debug});
    my $result = $ivtvObj->setInput($tunerFD, $preinput);
    if (!$result)
    {
      die "Error:  setInput($preinput) failed!\n";
    }
  }
}

# changes the video standard to $settings{VideoStandard} as long as it isn't = $curstd
sub change_standard {
  my $standard = $name2std{$settings{VideoStandard}};
  if($standard != $curStandard)
  {
    $curStandard = $standard;
    print "standard now $settings{VideoStandard}, #$standard\n" if ($settings{Debug});
    my $result = $ivtvObj->setStandard($tunerFD, $standard);
    if (!$result)
    {
      die "Error:  setStandard($standard) failed!\n";
    }
  }
}

# changes the channel
# takes the channel to change
sub changeChannel
{
  my $ch = shift;
  my $freq = $CHANLIST{$settings{FrequencyTable}}->{$ch};
  my $driverf = ($freq * 16)/1000;

  print "Ch.$ch: $freq $driverf\n" if ($settings{Debug});

  if (!$ivtvObj->setFrequency($tunerFD, $settings{TunerNum}, $driverf))
  {
    die "Error:  changeChannel($ch) failed!\n";
  }
}

# tunes to the specified frequency
# takes the frequency to tune to
sub tuneFrequency
{
  my $freq = shift;
  my $driverf = ($freq * 16)/1000;

  print "freq: $freq $driverf\n" if ($settings{Debug});

  if (!$ivtvObj->setFrequency($tunerFD, $settings{TunerNum}, $driverf))
  {
    die "Error:  tuneFrequency($freq) failed!\n";
  }
}

my $done = 0;

sub catch_alarm {
  $done = 1;
}

# does the actual video capturing work.
# takes directoryName, RecordDuration, OutputFileName, tuner
sub captureVideo
{
  my %args = ( @_ );
  my $directoryName = $args{directoryName};
  my $RecordDuration = $args{RecordDuration};
  my $OutputFileName = $args{OutputFileName};
  my $tuner = $args{tuner};
  my $fname = "$directoryName/$OutputFileName";
  my $DATE = '';

  # setup global variables, signal handlers, etc.

  $SIG{ALRM} = \&catch_alarm;
  $SIG{INT}  = \&catch_alarm;  # handle Ctrl-C

  # turn off file buffering.
  #$|=1;

  # open the file for writing.

  sysopen(OUTPUT, "$fname", O_CREAT | O_WRONLY | O_LARGEFILE) or die "Error creating file '$fname': $!\n";

  alarm($RecordDuration);
  my $buf = "";
  print "Waiting to Start...\n";
  for($i=0;$i<100;$i++) {
    read($tuner, $buf, 16384)
  }
  $DATE=`date`;
  print "Starting at $DATE";
  while (!$done && read($tuner, $buf, 16384))
  {
    # read from the device and write to the file.
    print OUTPUT $buf;
  }
  $DATE=`date`;
  print "Ending at $DATE";

  # close the file
  close(OUTPUT);

  #$|=0;  # turn file buffering back on.
}

# returns the formatted directory string
sub formatDirectoryString
{
  my $temp = $settings{DirectoryFormatString};
  my $result = $settings{OutputDirectory};
  my %lookupTable = (
    "d" => `/bin/date "$settings{DateTimeFormatString}"`,
    "I" => $settings{InputName},
    "c" => $settings{Channel},
  );

  # fixup the InputName value
  $lookupTable{I} =~ s/\s/_/g;
  # cleanup the trailing slash on the date
  chomp $lookupTable{d};

  foreach my $option ("d", "I", "c")
  {
    $temp =~ s/\%$option/$lookupTable{$option}/g;
  }

  $result .= "/" . ($temp ? "$temp/" : "");

  return $result;
}

sub outputSettingSetup
{
  my $date = `/bin/date`; chomp $date;

  if ($settings{OutputSettingsType} eq "shell")
  {
    print $settingsFH "# Settings for Recording made on $date.\n";
  }
  elsif ($settings{OutputSettingsType} eq "perl")
  {
    print $settingsFH "# Settings for Recording made on $date.\n";
    print $settingsFH "my %settings = ();\n";
  }
}

# outputs the specified setting and it's value to the
# settings file represented by $settingsFH in the
# specified language.
sub outputSetting
{
  my $setting = shift;
  my $value = $settings{$setting};
  
  return if (!$settings{OutputSettings});

  if ($settings{OutputSettingsType} eq "shell")
  {
    print $settingsFH "REC_" . uc($setting) . "=\"$value\"\n";
  }
  elsif ($settings{OutputSettingsType} eq "perl")
  {
    print $settingsFH "\$settings{$setting} = \"$value\";\n";
  }
}
