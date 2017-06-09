# tSort
An Igor Pro GUI which offers a spike sorting environment for extracellular unit recordings.

## Getting Started

### Prerequisites
* IGOR Pro 6 (https://www.wavemetrics.com/)
* tUtility (https://github.com/yuichi-takeuchi/tUtility)
* SetWindowExt.XOP (http://fermi.uchicago.edu/freeware/LoomisWood/SetWindowExt.shtml)

This code has been tested in Igor Pro version 6.3.7.2. for Windows and supposed to work in Igor Pro 6.1 or later.

### Installing
1. Install Igor Pro 6.1 or later.
2. Put GlobalProcedure.ipf of tUtility or its shortcut into the Igor Procedures folder, which is normally located at My Documents\WaveMetrics\Igor Pro 6 User Files\Igor Procedures.
3. SetWindowExt.xop or its shortcut into the Igor Extensions folder, which is normally located at My Documents\WaveMetrics\Igor Pro 6 User Files\Igor Extensions.
4. Optional: SetWindowExt Help.ipf or its shortcut into the Igor Help Files folder, which is normally located at My Documents\WaveMetrics\Igor Pro 6 User Files\Igor Help Files.
5. Put tSort.ipf or its shortcut into the Igor Procedure folder.
6. Restart Igor Pro.

### How to initialize the tSort GUI
* Click "tSortInitialize" in "Initialize" submenu of "tSort" menu.
* Main control panel (tSortMainControlPanel), main graph (tSortMainGraph), event graph (tSortEventGraph), master table (tSortMasterTable), and slave table (tSortSlabeTable) windows will appear.

### How to use 
1. 

#### Analsysis of spontaneous firing
1. 

#### Anasysis of evoked firing (peri-stimulus time histogram)
1. 

#### Making outputs
* Gizmo

### Help
* Click "Help" in "tSort" menu.

## DOI

## Versioning
We use [SemVer](http://semver.org/) for versioning.

## Releases
* Prerelease, 2017/06/06

## Authors
* **Yuichi Takeuchi PhD** - *Initial work* - [GitHub](https://github.com/yuichi-takeuchi)
* Affiliation: Department of Physiology, University of Szeged, Hungary
* E-mail: yuichi-takeuchi@umin.net

## License
This project is licensed under the MIT License.

## Acknowledgments
* Department of Physiology, Tokyo Women's Medical University, Tokyo, Japan
* John Economides (http://www.igorexchange.com/project/GenSpikeSorting)

## References
tSort has been used for the following works:

* Takeuchi Y, Osaki H, Yagasaki Y, Katayama Y, Miyata M (2017) Afferent Fiber Remodeling in the Somatosensory Thalamus of Mice as a Neural Basis of Somatotopic Reorganization in the Brain and Ectopic Mechanical Hypersensitivity after Peripheral Sensory Nerve Injury. eNeuro 4:e0345-0316.
