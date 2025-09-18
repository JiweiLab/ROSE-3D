# ROSE-3D Software README

This package is supplementary software for the manuscript "Molecular-scale Isotropic 3D Super-Resolution Microscopy via Interference Localization". It contains the software for demonstrating ROSE-3D reconstruction. It also includes a script for calculating the Cramér-Rao Lower Bound (CRLB).

## Reconstruction Demo

A demo dataset is available at [https://doi.org/10.6084/m9.figshare.30136318](https://doi.org/10.6084/m9.figshare.30136318) . Please download the dataset before running this demo. To run the full reconstruction demo:

1.Navigate to the folder "**Reconstruction**".

2.Add the folder "**lib**" to the MATLAB search path; this folder contains private functions required during reconstruction.

3.The folder "**RCC3D**" contains functions for RCC drift correlation, which will be called automatically during reconstruction.

4.To run the reconstruction, open and edit the script `run_Reconstruction.m` set the variable "**filename**" to the corresponding path of image file. There are two sets of image files acquired by two cameras, containing "_A" and "_B" in filenames for each set. The path should be the first file contains"**_A**" in the filename, such as "..\data\spool_A_MMStack_Pos0.ome.tif". Then run the script.

5.Finally, the reconstructed image is generated and saved as an image file.
The script will run automatically and display a summary report upon completion. Please note that, due to the small size of this demo dataset, the reconstruction will not produce a continuous image. A larger image dataset is available upon reasonable request to the authors.

## CRLB Calculation Demo

To run the CRLB calculation demo:

1.Navigate to the folder "**CRLB**".

2.Run the script `run_z_vs_crlb.m`.
This script calculates the CRLB for centroid fitting and ROSE-3D localization, and compares their performance. The relevant parameters are defined at the beginning of the script and can be modified as needed.

## License

© 2024 Ji Wei Group

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
Additionally, any use of the Software should include an acknowledgment of the original source, referencing © 2024 Ji Wei Group.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
