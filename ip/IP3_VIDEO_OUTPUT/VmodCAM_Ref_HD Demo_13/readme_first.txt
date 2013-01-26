This project has dependencies in the 'digilent' VHDL library. For your convenience
a local copy of these dependencies are included in the remote_sources directory.

The VmodCAM_Ref_HD demo project was built around an Atlys+VmodCAM setup.
The project configures the two cameras on the VmodCAM for maximum resolution
and frame rate, RGB output and video snapshot mode. The DDR memory on-board
the Atlys is used as a frame buffer. The two video feeds from both cameras are
bufferd in the DDR, while the FPGA drives the HDMI out port with either of the
cameras. Switch 7 selects the camera which gets displayed. The resolution of
the cameras (1600x1200) gets cropped to fit the display resolution of 1600x900.

Project built in ISE 13.2, tested in ISE 13.1.