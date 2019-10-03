# phaseSegmentator
The *phaseSegmentator* computer program enables the discrimination and segmentation of crystallographically identical/similar phases with grains of distinct orientation and slight compositional differences. The program uses reindexed EBSD datasets and EDS elemental data to compute grain-median compositional differences between grains of the phases in question and segments these by determination of an optimal threshold value. 

## Prerequisites
The computer program was written and is executed within *MATLAB*. Further, the program makes use of the free crystallographic toolbox [*MTEX*](https://mtex-toolbox.github.io/). Compatibility has been tested with *MATLAB R2016b* and *MTEX 5.1.1*. Since no advanced functions or functionalities of *MATLAB* or *MTEX* are applied, it is expected that the computer program is compatible for a wide range of the respective versions.

## File format
In the current version of *phaseSegmentator*, the EBSD input file format is *cpr/crc* and the output format is *ctf*. The [*MTEX* import wizard](https://mtex-toolbox.github.io/files/doc/ImportEBSDData.html#4) can be used to interactively import other EBSD file formats and to generate a function for automation of this step.

EDS data can either be imported together with the *cpr/crc* EBSD data using *MTEX* or read in from comma-separated value (*csv*) files. When using OI Aztec as an EBSD/EDS software suite, the latter version allows to import the image data of processed EDS data (TruMaps) while the prior method seems to import unprocessed EDS data. Import through *csv* is therefore adviced to obtain a possibly strong compositional contrast as a foundation for phase discrination and segmentation.
