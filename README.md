# AudioSwitch

This script adds an icon to the task which changes the audio device on a single click.
The icon reflects the current audio device.

## Installation

1. First, install the AudioDeviceCmdlets. Follow the instructions on https://github.com/frgnca/AudioDeviceCmdlets.
2. Configure the device ids in `Switch-Audio.ps1`.
3. Run the `Switch-Audio.ps1` script once to generate the shortcut. Currently it's required to pin the shortcut to the task bar manually the first time, or it won't stick.
