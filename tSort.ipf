#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 1.0.0	
#pragma IgorVersion = 6.1	//Igor Pro 6.1 or later
#include <XYZToTripletToXYZ>

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// This procedure (tSort) offers an analytical environment for extracellular unit recordings.
// Latest version is available at Github (https://github.com/yuichi-takeuchi/tSort).
//
// Prerequisites:
//* Igor Pro 6.1 or later
//* tUtility (https://github.com/yuichi-takeuchi/tUtility)
//* SetWindowExt.XOP (http://fermi.uchicago.edu/freeware/LoomisWood/SetWindowExt.shtml)
//
// Author:
// Yuichi Takeuchi PhD
// Department of Physiology, University of Szeged, Hungary
// Email: yuichi-takeuchi@umin.net
// 
// Lisence:
// MIT License
//
// Acknowledgments
// John Economides (http://www.igorexchange.com/project/GenSpikeSorting) 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Menu "tSort"
	SubMenu "Misc"
	End
"-"
	SubMenu "Initialize"
		"tSortInitialize", tSort_Initialize()
		"InitializeGVs&Waves", tSort_MainGVsWaves()
	End

	SubMenu "Main Control"
		"New Control", tSort_MainControlPanel()
		"Display Control", tSort_DisplayMain()
		"Hide Control", tSort_HideMainControlPanel()
		"Close Control", DoWindow/K tSortMainControlPanel
		".ipf",  DisplayProcedure/W= 'tSort.ipf' "tSort_MainControlPanel"
	End

	SubMenu "Master Table"	
		"New Master Table", tSort_MasterTable()
		"Display Master Table", tSort_DisplayMasterTable()
		"Hide Master Table", tSort_HideMasterTable()
		"Close Master Table", DoWindow/K tSortMasterTable
		".ipf", DisplayProcedure/W= 'tSort.ipf' "tSort_MasterTable"
	End

	SubMenu "Slave Table"	
		"New Slave Table", tSort_SlaveTable()
		"Display Slave Table", tSort_DisplaySlaveTable()
		"Hide Slave Table", tSort_HideSlaveTable()
		"Close Slave Table", DoWindow/K tSortSlaveTable
		".ipf", DisplayProcedure/W= 'tSort.ipf' "tSort_SlaveTable"
	End
	
	SubMenu "Main Graph"	
		"New Main Graph", tSort_MainGraph()
		"Display Main Graph", tSort_DisplayMainGraph()
		"Hide Main Graph", tSort_HideMainGraph()
		"Close Main Graph", DoWindow/K tSortMainGraph
		".ipf", DisplayProcedure/W= 'tSort.ipf' "tSort_MainGraph"
	End

	SubMenu "Event Graph"	
		"New Event Graph", tSort_EventGraph()
		"Display Event Graph", tSort_DisplayEventGraph()
		"Hide Event Graph", tSort_HideEventGraph()
		"Close Event Graph", DoWindow/K tSortEventGraph
		".ipf", DisplayProcedure/W= 'tSort.ipf' "tSort_EventGraph"
	End

	SubMenu "tSort.ipf"
		"Display Procedure", DisplayProcedure/W= 'tSort.ipf'
		"Main Control",  DisplayProcedure/W= 'tSort.ipf' "tSort_MainControlPanel"
		"Master Table", DisplayProcedure/W= 'tSort.ipf' "tSort_MasterTable"
		"Slave Table", DisplayProcedure/W= 'tSort.ipf' "tSort_SlaveTable"
		"Main Graph", DisplayProcedure/W= 'tSort.ipf' "tSort_MainGraph"
		"Event Graph", DisplayProcedure/W= 'tSort.ipf' "tSort_EventGraph"
	End

	
	"Kill All", tSort_KillAllWindows()
"-"
	"Help", tSort_HelpNote("")
End

Menu "GraphMarquee"

End

///////////////////////////////////////////////////////////////////////////
//Menu

Function tSort_FolderCheck()
	If(DataFolderExists("root:Packages:tSort"))
		else
			If(DataFolderExists("root:Packages"))
					NewDataFolder root:Packages:tSort
				else
					NewDataFolder root:Packages
					NewDataFolder root:Packages:tSort
			endif
	endif
End

Function tSort_Initialize()
	tSort_FolderCheck()
	tSort_PrepWaves()
	tSort_PrepGVs()	
	tSort_MainControlPanel()
	tSort_SlaveTable()
//	tSort_HideSlaveTable()
	tSort_MasterTable()
	tSort_MainGraph()
	tSort_EventGraph(72.75,198.5,342,453.5)
End

Function tSort_MainGVsWaves()
	tSort_FolderCheck()
	tSort_PrepWaves()
	tSort_PrepGVs()
end

Function tSort_PrepWaves()
	tSort_FolderCheck()
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort

	If(Exists("MainGraphSampleWave")==1)
	else
		Make/n=1000 MainGraphSampleWave
	endif

	Wave MainGraphSampleWave
	MainGraphSampleWave = gnoise(1)

	If(Exists("HighlightedEvent")==1)
	else
		Make/n=1 HighlightedEvent
	endif
	
	If(Exists("Event_1")==1)
	else
		Make/n=100 Event_1
		Wave Event_1
		Event_1 = gnoise(1)
	endif
	
	If(Exists("MainGraphIndex")==1)
	else
		Make/n=0 MainGraphIndex
	endif
	Redimension/n=0 MainGraphIndex

	If(Exists("MainGraphBIndex")==1)
	else
		Make/n=0 MainGraphBIndex
	endif
	Redimension/n=0 MainGraphBIndex

	If(Exists("MainGraphNBIndex")==1)
	else
		Make/n=0 MainGraphNBIndex
	endif
	Redimension/n=0 MainGraphNBIndex
	
	If(Exists("MainGraphSerial0")==1)
	else
		Make/n=0 MainGraphSerial0
	endif
	Redimension/n=0 MainGraphSerial0

	If(Exists("MainGraphXLock")==1)
	else
		Make/n=0 MainGraphXLock
	endif
	Redimension/n=0 MainGraphXLock
	
	If(Exists("tSortListWave") == 1)
	else
		Make/n=(1,5)/T tSortListWave
		SetDimLabel 1, 0, Spike, tSortListWave
		SetDimLabel 1, 1, LFP, tSortListWave
		SetDimLabel 1, 2, ECoG, tSortListWave
		SetDimLabel 1, 3, EMG, tSortListWave
		SetDimLabel 1, 4, Marker, tSortListWave
	endIf
	
	If(Exists("tSortSpontaListWave") == 1)
	else
		Make/n=0/T tSortSpontaListWave
	endIf
	
	If(Exists("tSortMasterLb2D") == 1)
	else
		Make/n=(1, 14)/T tSortMasterLb2D
	endIf
	tSortMasterLb2D = ""

	If(Exists("tSortSlaveLb2D") == 1)
	else
		Make/n=(1, 14)/T tSortSlaveLb2D
	endIf
	tSortSlaveLb2D = ""
	
	SetDataFolder fldrSav0
end

Function tSort_PrepGVs()
	tSort_FolderCheck()
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort

	String/G tWaveSort = "srcWave"
	String/G StrWeightList = "8;2;2;2;2;1;1;1;"

	Variable/G SpikeRange = 0.0025
	Variable/G DetectSpikeAmp = 0.0001
	Variable/G DetectSpikeSD = 3
	Variable/G DetectSmoothingBox = 10
	Variable/G DetectTightness = 50
	Variable/G DetectTightBack = 50
	Variable/G DetectRefCriteria = 0.001
	Variable/G bitDispMode = 0
	Variable/G MainGraphSecureVal = 1.2
	Variable/G MainGraphSpacerVal = 0.01
	Variable/G GraphHeight = 6
	Variable/G HistTrial = 0
	Variable/G HistCumTrial = 0
	Variable/G HistTimeWindow = 20
	Variable/G HistMarkerThreshold = 4
	Variable/G HistStdDev = 2
	Variable/G HistMean = 2
	Variable/G EventSerial = 1
	Variable/G EventIndex = 0
	Variable/G FocusWindow = 0.075
	Variable/G BurstingIEI = 0.005
	Variable/G PreBurstIEI = 0.02
	Variable/G BurstStartIEI = 0.006
	Variable/G BurstEndIEI = 0.01

	SetDataFolder fldrSav0
end

Function tSort_KillAllWindows()
	DoAlert 2, "All tSort Windows and Parameters are going to be killed. OK?"
	If(V_Flag != 1)
		Abort
	endif
	
	If(WinType("tSortMainControlPanel"))
		DoWindow/K tSortMainControlPanel
	endIf

	If(WinType("tSortMasterTable"))	
		 DoWindow/K tSortMasterTable
	endIf

	If(WinType("tSortSlaveTable"))	
		 DoWindow/K tSortSlaveTable
	endIf
	
	If(WinType("tSortMainGraph"))	
		 DoWindow/K tSortMainGraph
	endIf
	
	If(WinType("tSortEventGraph"))	
		 DoWindow/K tSortEventGraph
	endIf
end

Function  tSort_HelpNote(ctrlName) : ButtonControl
	String ctrlName
	
	NewNotebook/F=0
	String strhelp =""
	strhelp += "0. Click tSortInitialize						(Menu -> tSort -> Initialize -> tSortInitialize)"+"\r"
	strhelp += "1. Get WaveList				 			(Main Panel -> Main -> GetAll (Spike, LFP, ECoG, EMG, Marker Waves))"+"\r"
	strhelp += "2. Set Extract Parameters		 			(Main Panel -> Extract -> Spike Detection"+"\r"
	strhelp += "3. Set sourse wave					 	(Main Panel -> Main -> srcWave button)"+"\r"
	strhelp += "4. Preparations							(Main Panel -> Main -> MTablePrep, DisplayInit)"+"\r"
	strhelp += "5. Spike Detection						(Main Panel -> AutoSearch button)"+"\r"
	strhelp += "6. Calculate parameters					(Main Panel -> EachParam button)"+"\r"
	strhelp += "7. Next sweep							(Main Graph -> Next Sw button)"+"\r"
	strhelp += "8. Repeat 5-7"+"\r"
	strhelp += "9. Extract Spike Events					(Event Graph -> Extract button)"+"\r"
	strhelp += "10. Reduce dimension						(Main Panel -> PCA -> PCA button)"+"\r"
	strhelp += "11. Do cluster analysis						(Main Panel -> Cluster -> Minimum -> FPC)"+"\r"
	strhelp += "12. Calculate IndexedIEI and PatternIndex		(MasterTable -> IndexedIEI, PatternIndex buttons)"+"\r"
	strhelp += "13. Sort BurstIndex						(Main Graph -> BurstIndex button)"+"\r"
	strhelp += " "+"\r"
	
	strhelp += ""+"\r"
	strhelp += "Analysis of Spontaneous Firing				(Main Panel -> Hist -> Spontaneous Mode)"+"\r"
	strhelp += "1. Preparation							(Main Panel -> Hist -> STablePrep button)"+"\r"
	strhelp += "2. Specify srcWave"+"\r"
	strhelp += "3. Display srcWave and Detect Spikes		(Main Panel -> Hist -> DisplayInit, AutoSearch buttons)"+"\r"
	strhelp += "4. Repeat 2 and 3."+"\r"
	strhelp += "5. Sort BurstIndex						(Slave Table -> BurstIndex button)"+"\r"
	strhelp += "6. Make Raster waves						(Main Panel -> Hist -> Raster button)"+"\r"
	strhelp += "7. SpontaHz and Histogram buttons"+"\r"
	strhelp += ""+"\r"
	strhelp += "Analysis of Evoked Firing (PSTH)			(Main Panel -> Hist -> PSTH Mode"+"\r"
	strhelp += "1. Preparation							(Main Panel -> Hist -> STablePrep button)"+"\r"
	strhelp += "2. Set Detection Parameters				(Main Panel -> Hist -> Trial, Cum Traial, Trial Mode, TimeWindows etc.)"+"\r"
	strhelp += "3. Specify srcWave"+"\r"
	strhelp += "4. Display srcWave and Detect Spikes		(Main Panel -> Hist -> DisplayInit, AutoSearch buttons)"+"\r"
	strhelp += "5. Repeat 3 and 4."+"\r"
	strhelp += "6. Sort BurstIndex						(Slave Table -> BurstIndex button)"+"\r"
	strhelp += "7. Make Raster waves						(Main Panel -> Hist -> Raster button)"+"\r"
	strhelp += "8. Histogram button"+"\r"
	strhelp += ""+"\r"
	strhelp += "Reports"+"\r"
	strhelp += "tWaveSortGraph (Select Display Mode before Do it)"+"\r"
	strhelp += "EachTrialGraph (Specify Trianl No. before Do it)"+"\r"
	strhelp += "AllTrialGraph"+"\r"
	strhelp += "PlainEvents"+"\r"
	strhelp += "NewPCGizmo"+"\r"
	strhelp += "ExportGizmo (EPS)"+"\r"
	strhelp += ""+"\r"
	Notebook $WinName(0, 16) selection={startOfFile, endOfFile}
	Notebook $WinName(0, 16) text = strhelp + "\r"
end
///////////////////////////////////////////////////////////////////////////
//Main Control Panel

Function tSort_MainControlPanel()
	NewPanel /N=tSortMainControlPanel/W=(748,57,1265,226)
	TabControl TabtSortMain,pos={2,1},size={514,167},proc=tSort_MainTabProc
	TabControl TabtSortMain,tabLabel(0)="Main",tabLabel(1)="DispMode"
	TabControl TabtSortMain,tabLabel(2)="Extract",tabLabel(3)="Field"
	TabControl TabtSortMain,tabLabel(4)="Cluster", tabLabel(5)="Hist"
	TabControl TabtSortMain,value= 0
	
//tab0 (Main)
	Button BtSelecttWave_tab0,pos={8,25},size={70,20},proc=tSort_SelectSrcW,title="srcWave"
	SetVariable SetVartWaveSort_tab0,pos={88,28},size={100,16},title=" ",value= root:Packages:tSort:tWaveSort
	PopupMenu PoptWave_tab0,pos={15,50},size={111,20},bodyWidth=75,proc=tSort_WaveSelection0,title="select",mode=1,popvalue="select",value= #"wavelist(\"*\", \";\", \"\")"
	PopupMenu PoptWaveAddition_tab0,pos={19,75},size={98,20},bodyWidth=75,proc=tSort_WaveAddition0,title="add",mode=1,popvalue="add",value= #"wavelist(\"*\", \";\", \"\")"
	ListBox SortWaveList_tab0,pos={155,50},size={350,100},frame=2,listWave=root:Packages:tSort:tSortListWave,mode= 1,selRow= 0

	Button BtMainGetAll_tab0,pos={204,25},size={50,20},proc=tSort_GetAllWaves,title="GetAll"
	Button BtMainGetWL_tab0,pos={254,25},size={50,20},proc=tSort_GetWaveList,title="GetWL"
	Button BtDeleteListWave_tab0,pos={304,25},size={50,20},proc=tSort_DeleteWaveList,title="Delete"
	Button BtEditSort_tab0,pos={354,25},size={50,20},proc=tSort_EditList,title="EditList"

	Button BtMasterTablePrep_tab0,pos={8,95},size={70,20},proc=tSort_MasterTablePrep,title="MTablePrep"
	Button BtDisplayInittWave_tab0,pos={8,115},size={70,20},proc=tSort_MainDisplayInitialize,title="DisplayInit"
	Button BtAutoSearch_tab0,pos={78,95},size={70,20},proc=tSort_AutoSearch,title="AutoSearch"
	Button BtSetEachParam_tab0,pos={78,115},size={70,20},proc=tSort_SetEachParamMainGraph,title="EachParam"

//tab1 (DispMode)
	Button BtMainGraphTransform_tab1,pos={20,30},size={70,20},proc=tSort_MainGraphTransform,title="Transform"
	ValDisplay ValbitDispMode_tab1,pos={105,33},size={95,13},title="bitDispMode",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:tSort:bitDispMode"
	SetVariable SetStrWeightList_tab1,pos={210,31},size={120,16},title="Weight",value= root:Packages:tSort:StrWeightList
	SetVariable SetGraphHeight_tab1,pos={337,31},size={130,16},proc=tSort_ModifiyGraphHeight,title="GraphHeight (cm)",limits={1,inf,1},value= root:Packages:tSort:GraphHeight
	SetVariable SetSecureVal_tab1,pos={20,57},size={120,16},title="SecureVal",limits={0.5,1.5,0.01},value= root:Packages:tSort:MainGraphSecureVal
	SetVariable SetSpacerVal_tab1,pos={160,57},size={120,16},title="SpacerVal",limits={0,0.2,0.01},value= root:Packages:tSort:MainGraphSpacerVal	
	CheckBox CheckSpike_tab1,pos={20,85},size={70,14},proc=tSort_bitDispModeoFromCheck,title="0.Spike",value= 1
	CheckBox CheckLFP_tab1,pos={120,85},size={70,14},proc=tSort_bitDispModeoFromCheck,title="1.LFP",value= 0
	CheckBox CheckECoG_tab1,pos={220,85},size={70,14},proc=tSort_bitDispModeoFromCheck,title="2.ECoG",value= 0
	CheckBox CheckEMG_tab1,pos={320,85},size={70,14},proc=tSort_bitDispModeoFromCheck,title="3.EMG",value= 0
	CheckBox CheckMarker_tab1,pos={420,85},size={70,14},proc=tSort_bitDispModeoFromCheck,title="4.Marker",value= 0
	CheckBox CheckIndex_tab1,pos={20,105},size={70,14},proc=tSort_bitDispModeoFromCheck,title="5.Index",value= 1
	CheckBox CheckBurstIndex_tab1,pos={120,105},size={70,14},proc=tSort_bitDispModeoFromCheck,title="6.Burst",value= 0
	CheckBox CheckNonBurstIndex_tab1,pos={220,105},size={70,14},proc=tSort_bitDispModeoFromCheck,title="7.NonBurst",value= 0
	tSort_bitDispModeoFromCheck("", NaN)
	PopupMenu Popup_IndexType_tab1,pos={20,125},size={61,20},proc=tSort_IndexMarkerType,title="Index",mode=1,popvalue="|",value= #"\"|;Serial0\""
	PopupMenu Popup_BurstType_tab1,pos={120,125},size={61,20},proc=tSort_BurstMarkerType,title="Burst",mode=1,popvalue="",value=  #"\"*MARKERPOP*\""
	PopupMenu Popup_NonBurstType_tab1,pos={220,125},size={61,20},proc=tSort_NonBurstMarkerType,title="NonBusrt",mode=1,popvalue="",value= #"\"*MARKERPOP*\""

//tab2 (Extract)
	GroupBox GroupSpike_tab2,pos={15,25},size={237,135},title="Spike Detection"
	PopupMenu PopupSpikeDetect_tab2,pos={31,41},size={76,20},title="Polarity",mode=1,popvalue="+",value= #"\"+;-;±;\""
	SetVariable SetSpikeAmplitude_tab2,pos={32,64},size={150,16},title="Amp (V)",limits={0,inf,1e-6},value= root:Packages:tSort:DetectSpikeAmp
	SetVariable SetSpikefromSD_tab2,pos={33,87},size={75,16},title="×S.D.",limits={0,inf,1},value= root:Packages:tSort:DetectSpikeSD
	Button BtSDAmp_tab2,pos={115,85},size={50,20},proc=tSort_AmpSD,title="AmpSD"
	SetVariable SetSpikeBox_tab2,pos={28,109},size={130,16},title="Smoothing (Box)",limits={0,inf,1},value= root:Packages:tSort:DetectSmoothingBox
	SetVariable SetTightnessBack_tab2,pos={26,131},size={90,16},title="TightBack",limits={0,inf,1},value= root:Packages:tSort:DetectTightBack
	SetVariable SetTightness_tab2,pos={132,131},size={90,16},title="Tightness",limits={0,inf,1},value= root:Packages:tSort:DetectTightness
	GroupBox GroupRefractory_tab2,pos={287,29},size={208,64},title="Refractory Criteria"
	SetVariable SetDetect_RefCri_tab2,pos={300,50},size={150,16},limits={0,inf,0.0001},value= root:Packages:tSort:DetectRefCriteria

//tab3 (Field)
	GroupBox GroupExtract_tab3,pos={11,23},size={195,125},title="Extract"
	CheckBox CheckSerial0_tab3,pos={20,40},size={70,14},title="Serial0",value= 1
	CheckBox CheckRecNum_tab3,pos={20,60},size={70,14},title="RecNum",value= 0
	CheckBox CheckwvName_tab3,pos={20,80},size={70,14},title="wvName",value= 1
	CheckBox CheckXLock_tab3,pos={20,100},size={70,14},title="XLock",value= 1
	CheckBox CheckIEI_tab3,pos={20,120},size={70,14},title="IEI",value= 1
	CheckBox CheckBase_tab3,pos={120,40},size={70,14},title="Base",value= 1
	CheckBox CheckAmplitude_tab3,pos={120,60},size={70,14},title="Amplitude",value= 1
	CheckBox CheckHalfW_tab3,pos={120,80},size={70,14},title="HalfW",value= 1
	CheckBox CheckIndexedIEI_tab3,pos={120,100},size={70,14},title="IndexedIEI",value= 1
	CheckBox CheckPatternIndex_tab3,pos={120,120},size={70,14},title="PatternIndex",value= 1

	GroupBox GroupCluster_tab3,pos={211,23},size={95,125},title="Cluster"
	CheckBox CheckPC1_tab3,pos={220,40},size={70,14},title="PC1",value= 1
	CheckBox CheckPC2_tab3,pos={220,60},size={70,14},title="PC2",value= 1
	CheckBox CheckPC3_tab3,pos={220,80},size={70,14},title="PC3",value= 1
	CheckBox CheckIndex_tab3,pos={220,100},size={70,14},title="Index",value= 1

	GroupBox GroupHistogram_tab3,pos={311,23},size={195,125},title="Histogram"
	CheckBox CheckSerial1_tab3,pos={320,40},size={70,14},title="Serial1",value= 1
	CheckBox CheckwvNameSlave_tab3,pos={320,60},size={70,14},title="wvName",value= 1
	CheckBox CheckTrial_tab3,pos={320,80},size={70,14},title="Trial",value= 1
	CheckBox CheckTimeLocked_tab3,pos={320,100},size={70,14},title="TimeLocked",value= 1
	CheckBox CheckIndexSlave_tab3,pos={320,120},size={70,14},title="Index",value= 1
	CheckBox CheckPIndexSlave_tab3,pos={420,40},size={70,14},title="PatternIndex",value= 1
	CheckBox CheckBIndexSlave_tab3,pos={420,60},size={70,14},title="BurstIndex",value= 1	
	CheckBox CheckNBIndexSlave_tab3,pos={420,80},size={70,14},title="NBurstIndex",value= 1		
	CheckBox CheckSerialRef_tab3,pos={420,100},size={70,14},title="SerialRef",value= 1
	CheckBox CheckTrigger_tab3,pos={420,120},size={70,14},title="Trigger",value= 1
	
	GroupBox GroupBurstCriteria_tab4,pos={354,22},size={150,100},title="Burst Criteria"
	
//tab4 (Cluster)
	Button BtPCA_tab4,pos={15,39},size={50,20},proc=tSort_PCA,title="PCA"
	GroupBox GroupClusterMin_tab4,pos={75,22},size={140,45},title="Minimum"
	Button BtFPClusterMin_tab4,pos={90,39},size={50,20},proc=tSort_FPClusterMin,title="FPC"
	Button BtKMeansClusterMin_tab4,pos={150,39},size={50,20},proc=tSort_KMeansClusterMin,title="KMeans"
	GroupBox GroupClusterJohnEconomides_tab4,pos={75,72},size={140,45},title="John Economides"
	Button BtFPCluster_tab4,pos={90,87},size={50,20},proc=tSort_FPCluster,title="FPC"
	Button BtKMeansCluster_tab4,pos={150,87},size={50,20},proc=tSort_KMeansCluster,title="KMeans"

	CheckBox CheckBurstingIEI_tab4,pos={220,30},size={119,14},title="ConsiderBurstingIEI",value= 1
	SetVariable SetvarBurstingIEI_tab4,pos={220,50},size={130,16},title="BurstingIEI",limits={0.001,inf,0.001},value= root:Packages:tSort:BurstingIEI

	GroupBox GroupBurstCriteria_tab4,pos={354,22},size={150,100},title="Burst Criteria"
	SetVariable SetvarPreBurstIEI_tab4,pos={365,40},size={130,16},title="PreBurstIEI (s)",limits={0.001,1,0.001},value= root:Packages:tSort:PreBurstIEI
	SetVariable SetvarBurstStartIEI_tab4,pos={365,65},size={130,16},title="BurstStartIEI (s)",limits={0.001,1,0.001},value= root:Packages:tSort:BurstStartIEI
	SetVariable SetvarBurstEndIEI_tab4,pos={365,90},size={130,16},title="BurstEndIEI (s)",limits={0.001,1,0.001},value= root:Packages:tSort:BurstEndIEI

//tab5 (Hist)
	Button BtSlaveTablePrep_tab5,pos={10,22},size={70,20},proc=tSort_SlaveTablePrep,title="STablePrep"
	Button BtDisplayInittWave_tab5,pos={10,42},size={70,20},proc=tSort_MainDisplayInitialize,title="DisplayInit"
	Button BtAutoSearch_tab5,pos={10,62},size={70,20},proc=tSort_AutoHistSearch,title="AutoSearch"
	Button BtManual_tab5,pos={80,62},size={50,20},proc=tSort_ManualHistSearch,title="Manual"
	Button BtHistRasterForEachTrial_tab5,pos={10,82},size={70,20},proc=tSort_HistRaster,title="Raster"
	Button BtHistSpontaHzNote_tab5,pos={10,102},size={70,20},proc=tSort_SpontaHz_Note,title="Sponta Hz"
	Button BtHistPromptPanel_tab5,pos={10,122},size={70,20},proc=tSort_HistoPromptPanelSwitch,title="Histogram"
	Button BtKillGraphs_tab5,pos={10,142},size={70,20},proc=tSort_KillGraphs,title="KillGraphs"
	
	Button BttWaveSortMasterGraph_tab5,pos={142,156},size={90,20},proc=tSort_tWaveSortGraph,title="tWaveSortGraph"
	Button BtEachTrialGraph_tab5,pos={142,176},size={90,20},proc=tSort_EachTrialGraph,title="EachTrialGraph"
	Button BtAllTrialGraph_tab5,pos={142,196},size={90,20},proc=tSort_AllTrialGraph,title="AllTrialGraph"
	Button BtPlainEventGraph_tab5,pos={142,216},size={90,20},proc=tSort_PlainEventGraph,title="PlainEvents"
	Button BtNewPCGizmo_tab5,pos={142,236},size={90,20},proc=tSort_NewPCGizmo,title="NewPCGizmo"
	Button BtExportGizmo_tab5,pos={142,256},size={90,20},proc=tSort_ExportGizmo,title="ExportGizmo"
	
	PopupMenu PopupHistAnalysisMode_tab5,pos={140,23},size={178,20},bodyWidth=100,title="Analysis Mode",mode=1,popvalue="PSTH",value= #"\"PSTH;Spontaneous;\""
	SetVariable SetvarHistTrial_tab5,pos={140,50},size={80,16},title="Trial",limits={0,inf,1},value= root:Packages:tSort:HistTrial
	SetVariable SetvarHistCumTrial_tab5,pos={230,50},size={90,16},title="Cum Trial",limits={0,inf,1},value= root:Packages:tSort:HistCumTrial
	SetVariable SetvarHistTimeWindow_tab5,pos={140,70},size={150,16},title="TimeWindow (s)",value= root:Packages:tSort:HistTimeWindow
	SetVariable SetvarHistMarkerThreshold_tab5,pos={140,90},size={170,16},title="MarkerThreshold (V)",value= root:Packages:tSort:HistMarkerThreshold
	SetVariable SetvarHistStdDev_tab5,pos={140,110},size={170,16},title="Standard Deviation",value= root:Packages:tSort:HistStdDev
	SetVariable SetvarHistMean_tab5,pos={140,130},size={170,16},title="Mean Baseline",value= root:Packages:tSort:HistMean
	
	Button BttWaveSortMasterGraph_tab5,pos={332,22},size={90,20},proc=tSort_tWaveSortGraph,title="tWaveSortGraph"
	Button BtEachTrialGraph_tab5,pos={332,42},size={90,20},proc=tSort_EachTrialGraph,title="EachTrialGraph"
	Button BtAllTrialGraph_tab5,pos={332,62},size={90,20},proc=tSort_AllTrialGraph,title="AllTrialGraph"
	Button BtPlainEventGraph_tab5,pos={332,82},size={90,20},proc=tSort_PlainEventGraph,title="PlainEvents"
	Button BtNewPCGizmo_tab5,pos={332,102},size={90,20},proc=tSort_NewPCGizmo,title="NewPCGizmo"
	Button BtExportGizmo_tab5,pos={332,122},size={90,20},proc=tSort_ExportGizmo,title="ExportGizmo"


//Not Neccesary?
//	PopupMenu PopupHistTrialMode_tab5,pos={330,48},size={157,20},bodyWidth=100,title="Trial Mode",mode=2,popvalue="Continuous",value= #"\"Discontinuous;Continuous;\""

//tab7 (Help)
//	Button BttSortHelpButton_tab7,pos={10,46},size={70,20},proc=tSort_HelpNote,title="Help"
	
//
	ModifyControlList ControlNameList("tSortMainControlPanel", ";", "!*_tab0") disable = 1
	ModifyControl TabtSortMain disable=0
end

Function tSort_MainTabProc(ctrlName,tabNum) : TabControl
	String ctrlName
	Variable tabNum
	
	String controlsInATab= ControlNameList("tSortMainControlPanel",";","*_tab*")
	String curTabMatch="*_tab*"+Num2str(tabNum)
	String controlsInCurTab= ListMatch(controlsInATab, curTabMatch)
	String controlsInOtherTab= ListMatch(controlsInATab, "!"+curTabMatch)
	ModifyControlList controlsInCurTab disable = 0 //show
	ModifyControlList controlsInOtherTab disable = 1 //hide
	return 0
End

Function tSort_DisplayMain()
	If(WinType("tSortMainControlPanel") == 7)
		DoWindow/HIDE = ? $("tSortMainControlPanel")
		If(V_flag == 1)
			DoWindow/HIDE = 1 $("tSortMainControlPanel")
		else
			DoWindow/HIDE = 0/F $("tSortMainControlPanel")
		endif
	else	
		tSort_MainControlPanel()
	endif
End

Function tSort_HideMainControlPanel()
	If(WinType("tSortMainControlPanel"))
		DoWindow/HIDE = 1 $("tSortMainControlPanel")
	endif
End

Function tSort_SelectSrcW(ctrlName) : ButtonControl
	String ctrlName
	
	SVAR tWaveSort = root:Packages:tSort:tWaveSort
	Wave/T ListWave = root:Packages:tSort:tSortListWave
	ControlInfo/W=tSortMainControlPanel SortWaveList_tab0
	tWaveSort = ListWave[V_Value]
End

Function tSort_WaveSelection0(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	SVAR tWaveSort = root:Packages:tSort:tWaveSort
	tWaveSort = popStr
	Wave/T ListWave = root:Packages:tSort:tSortListWave
//	Redimension/N=(1, 3) ListWave
//	ListWave[0][0] = {popStr}
End

Function tSort_WaveAddition0(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	SVAR tWaveSort = root:Packages:tSort:tWaveSort
	tWaveSort = popStr
	Wave/T ListWave = root:Packages:tSort:tSortListWave
	Redimension/N=(DimSize(ListWave, 0)+1, 3) ListWave
	ListWave[DimSize(ListWave, 0)-1][0] = {popStr}
End

Function tSort_GetAllWaves(ctrlName) : ButtonControl
	String ctrlName
	
	String StrLabelList = "spike;LFP;ECoG;EMG;marker;"
	String StrList = ""
	Variable i = 0
	Wave/T ListWave = root:Packages:tSort:tSortListWave
	Redimension/N=(Dimsize(ListWave, 0), 5) ListWave
	
	For(i=0; i<5; i+=1)
		String StrLabel = StringFromList(i, StrLabelList, ";")
		tSort_GetAllWaves2(i, WaveList("w_*"+StrLabel, ";", ""))
	endFor
End

Function tSort_GetAllWaves2(var, strlist)
	Variable var
	String strlist
	
	Wave/T ListWave = root:Packages:tSort:tSortListWave
	Variable i = 0
	
	ControlInfo/W=tSortMainControlPanel SortWaveList_tab0
	If(V_Value < 0)
		V_Value = 0
	endIf
	
	do
		String SFL = StringFromList(i, strlist, ";")
		If(Strlen(SFL)<1)
			break
		endIf
		If(var == 0)
			Insertpoints(V_value + i), 1, ListWave
		endIf
		ListWave[V_Value + i][var] = SFL
		i += 1
	while(1)
	
End


Function tSort_GetWaveList(ctrlName) : ButtonControl
	String ctrlName
	
	String StrColumn = ""
	String OWorIns = ""
	
	Prompt StrColumn, "Select column." , popup, "0 (spike);1 (LFP);2 (ECoG);3 (EMG);4 (Marker);"
	Prompt OWorIns, "Overwrite or Insert?", popup, "Overwrite;Insert;"
	DoPrompt "Set", StrColumn, OWorIns

	If(V_flag)
		Abort
	endIf
	
	Variable column
	String str
	sscanf StrColumn, "%f %s", column, str
	
	SVAR tWL = root:Packages:YT:tWL
	Wave/T ListWave = root:Packages:tSort:tSortListWave

	String SFL = ""
	Variable i = 0
	Redimension/N=(Dimsize(ListWave, 0), 5) ListWave

	ControlInfo/W=tSortMainControlPanel SortWaveList_tab0
	If(V_Value < 0)
		V_Value = 0
	endIf

	StrSwitch(OWorIns)
		case "Overwrite":
			do
				SFL = StringFromList(i, tWL, ";")
				If(Strlen(SFL)<1)
					break
				endIf
				ListWave[V_Value + i][column] = SFL
				i += 1
			while(1)
			
			break
		case "Insert":
			do
				SFL = StringFromList(i, tWL, ";")
				If(Strlen(SFL)<1)
					break
				endIf
				Insertpoints (V_value + i), 1, ListWave
				ListWave[V_value + i][column] = SFL
				i += 1
			while(1)
			break
		default:
			break
	endSwitch
End

Function tSort_DeleteWaveList(ctrlName) : ButtonControl
	String ctrlName
	
	Wave ListWave = root:Packages:tSort:tSortListWave
	ControlInfo/W=tSortMainControlPanel SortWaveList_tab0
	DeletePoints V_Value, 1, ListWave
End

Function tSort_EditList(ctrlName) : ButtonControl
	String ctrlName
	
	Wave ListWave = root:Packages:tSort:tSortListWave
	Edit ListWave
End

Function tSort_MasterTablePrep(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/F tSortMasterTable

	String fldrsav0 = GetDataFolder(1)
	SetDatafolder root:Packages:tSort:
	Variable labelnum = 0

	ControlInfo/W=tSortMainControlPanel CheckSerial0_tab3
	If(V_value)
		If(Exists("Serial0") != 1)
			Make/N=0 Serial0
		endif
		AppendToTable/W=tSortMasterTable#T0 Serial0
		SetDimLabel 1,labelnum,Serial0,tSortMasterLb2D
		labelnum += 1
	endIf

	ControlInfo/W=tSortMainControlPanel CheckwvName_tab3
	If(V_value)
		If(Exists("wvName") != 1)
			Make/T/N=0 wvName
		endif
		AppendToTable/W=tSortMasterTable#T0 wvName
		SetDimLabel 1,labelnum,wvName,tSortMasterLb2D
		labelnum += 1
	endIf

	ControlInfo/W=tSortMainControlPanel CheckXLock_tab3
	If(V_value)
		If(Exists("XLock") != 1)
			Make/N=0 XLock
		endif
		AppendToTable/W=tSortMasterTable#T0 XLock
		SetDimLabel 1,labelnum,XLock,tSortMasterLb2D
		labelnum += 1
	endIf

	ControlInfo/W=tSortMainControlPanel CheckIEI_tab3
	If(V_value)
		If(Exists("IEI") != 1)
			Make/N=0 IEI
		endif
		AppendToTable/W=tSortMasterTable#T0 IEI
		SetDimLabel 1,labelnum,IEI,tSortMasterLb2D
		labelnum += 1
	endIf

	If(Exists("Base") != 1)
		Make/N=0 Base
	endif
	ControlInfo/W=tSortMainControlPanel CheckBase_tab3
	If(V_value)
		AppendToTable/W=tSortMasterTable#T0 Base
		SetDimLabel 1,labelnum,Base,tSortMasterLb2D
		labelnum += 1
	endIf

	ControlInfo/W=tSortMainControlPanel CheckAmplitude_tab3
	If(V_value)
		If(Exists("Amplitude") != 1)
			Make/N=0 Amplitude
		endif
		AppendToTable/W=tSortMasterTable#T0 Amplitude
		SetDimLabel 1,labelnum,Amplitude,tSortMasterLb2D
		labelnum += 1
	endIf

	ControlInfo/W=tSortMainControlPanel CheckHalfW_tab3
	If(V_value)
		If(Exists("HalfW") != 1)
			Make/N=0 HalfW
		endif
		AppendToTable/W=tSortMasterTable#T0 HalfW
		SetDimLabel 1,labelnum,HalfW,tSortMasterLb2D
		labelnum += 1
	endIf

	ControlInfo/W=tSortMainControlPanel CheckPC1_tab3
	If(V_value)
		If(Exists("PC1") != 1)
			Make/N=0 PC1
		endif
		AppendToTable/W=tSortMasterTable#T0 PC1
		SetDimLabel 1,labelnum,PC1,tSortMasterLb2D
		labelnum += 1
	endIf

	ControlInfo/W=tSortMainControlPanel CheckPC2_tab3
	If(V_value)
		If(Exists("PC2") != 1)
			Make/N=0 PC2
		endif
		AppendToTable/W=tSortMasterTable#T0 PC2
		SetDimLabel 1,labelnum,PC2,tSortMasterLb2D
		labelnum += 1
	endIf

	ControlInfo/W=tSortMainControlPanel CheckPC3_tab3
	If(V_value)
		If(Exists("PC3") != 1)
			Make/N=0 PC3
		endif
		AppendToTable/W=tSortMasterTable#T0 PC3
		SetDimLabel 1,labelnum,PC3,tSortMasterLb2D
		labelnum += 1
	endIf

	ControlInfo/W=tSortMainControlPanel CheckIndex_tab3
	If(V_value)
		If(Exists("Index") != 1)
			Make/N=0 Index
		endif
		AppendToTable/W=tSortMasterTable#T0 Index
		SetDimLabel 1,labelnum,Index,tSortMasterLb2D
		labelnum += 1
	endIf

	ControlInfo/W=tSortMainControlPanel CheckIndexedIEI_tab3
	If(V_value)
		If(Exists("IndexedIEI") != 1)
			Make/N=0 IndexedIEI
		endif
		AppendToTable/W=tSortMasterTable#T0 IndexedIEI
		SetDimLabel 1,labelnum,IndexedIEI,tSortMasterLb2D
		labelnum += 1
	endIf
	
	ControlInfo/W=tSortMainControlPanel CheckPatternIndex_tab3
	If(V_value)
		If(Exists("PatternIndex") != 1)
			Make/N=0 PatternIndex
		endif
		AppendToTable/W=tSortMasterTable#T0 PatternIndex
		SetDimLabel 1,labelnum,PatternIndex,tSortMasterLb2D
		labelnum += 1
	endIf

	Redimension/N=(0,14) tSortMasterLb2D
	SetDataFolder fldrsav0
end

Function tSort_MainDisplayInitialize(ctrlName) : ButtonControl
	String ctrlName

	SVAR tWaveSort = root:Packages:tSort:tWaveSort
	NVAR bitDispMode = root:Packages:tSort:bitDispMode
	
	tSort_MakeLabelWave()
	If(StringMatch(ctrlName, "BtDisplayInittWave_tab0"))
		tSort_CopyLabelWave(1, tWaveSort)
	else
		tSort_CopyLabelWave(0, tWaveSort)
	endIf
//	tSort_BaselineSubtraction(tWaveSort)
	tSort_CleartSortMainGraph()
	
	Wave/T ListWave = root:Packages:tSort:tSortListWave
	ControlInfo/W=tSortMainControlPanel SortWaveList_tab0
	If(V_value < 0)
		V_value = 0
	endIf

	String StrSpikeWave = ListWave[V_value][0]
	String StrLFPWave = ListWave[V_value][1]
	String StrECoGWave = ListWave[V_value][2]
	String StrEMGWave = ListWave[V_value][3]
	String StrMarkerWave = ListWave[V_value][4]

	tWaveSort = StrSpikeWave

	Wave SpikeWave = $StrSpikeWave
	Wave LFPWave = $StrLFPWave
	Wave ECoGWave = $StrECoGWave
	Wave EMGWave = $StrEMGWave
	Wave MarkerWave = $StrMarkerWave
	Wave MainGraphIndex = root:Packages:tSort:MainGraphIndex
	Wave MainGraphBIndex = root:Packages:tSort:MainGraphBIndex
	Wave MainGraphNBIndex = root:Packages:tSort:MainGraphNBIndex
	Wave MainGraphXLock = root:Packages:tSort:MainGraphXLock

	If(bitDispMode & 2^0)
		AppendToGraph/W=tSortMainGraph SpikeWave
	endIf

	If(bitDispMode & 2^1)
		AppendToGraph/L=LFPAxis LFPWave
	endIf

	If(bitDispMode & 2^2)
		AppendToGraph/L=ECoGAxis ECoGWave
	endIf

	If(bitDispMode & 2^3)
		AppendToGraph/L=EMGAxis EMGWave
	endIf

	If(bitDispMode & 2^4)
		AppendToGraph/L=MarkerAxis MarkerWave
	endIf
	
	If(bitDispMode & 2^5)
		AppendToGraph/L=IndexAxis MainGraphIndex vs MainGraphXLock
	endIf
		
	If(bitDispMode & 2^6)
		AppendToGraph/L=BIndexAxis MainGraphBIndex vs MainGraphXLock
	endIf
		
	If(bitDispMode & 2^7)
		AppendToGraph/L=NBIndexAxis MainGraphNBIndex vs MainGraphXLock
	endIf
	
	tSort_MainGraphTransform("")
//	SetAxis/W=tSortMainGraph bottom 0,2
End

Function tSort_MakeLabelWave()
	SVAR tWaveSort = root:Packages:tSort:tWaveSort
	
	String LabelMainGraphIndex = tWaveSort + "_MGIndex"
	String LabelMainGraphBIndex = tWaveSort + "_MGBIndex"
	String LabelMainGraphNBIndex = tWaveSort + "_MGNBIndex"
	String LabelMainGraphSerial0 =  tWaveSort + "_MGSerial0"
	String LabelMainGraphXLock = tWaveSort + "_MGXLock"
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		If(Exists(LabelMainGraphIndex) == 0)
			Make/n=0 $LabelMainGraphIndex
		endIf

		If(Exists(LabelMainGraphBIndex) == 0)
			Make/n=0 $LabelMainGraphBIndex
		endIf

		If(Exists(LabelMainGraphNBIndex) == 0)
			Make/n=0 $LabelMainGraphNBIndex
		endIf
		
		If(Exists(LabelMainGraphSerial0) == 0)
			Make/n=0 $LabelMainGraphSerial0
		endIf

		If(Exists(LabelMainGraphXLock) == 0)
			Make/n=0 $LabelMainGraphXLock
		endIf
	SetDataFolder fldrSav0
End

Function tSort_CopyLabelWave(var, str)
	Variable var
	String str
	
	String LabelMainGraphIndex = str + "_MGIndex"
	String LabelMainGraphBIndex = str + "_MGBIndex"
	String LabelMainGraphNBIndex = str + "_MGNBIndex"
	String LabelMainGraphSerial0 = str + "_MGSerial0"
	String LabelMainGraphXLock = str + "_MGXLock"
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		Wave MainGraphIndex, MainGraphBIndex, MainGraphNBIndex, MainGraphXLock
		Wave wLabelMainGraphIndex = $LabelMainGraphIndex
		Wave wLabelMainGraphBIndex = $LabelMainGraphBIndex
		Wave wLabelMainGraphNBIndex = $LabelMainGraphNBIndex
		Wave wLabelMainGraphSerial0 = $LabelMainGraphSerial0
		Wave wLabelMainGraphXLock = $LabelMainGraphXLock

		If(var)
			Duplicate/O MainGraphIndex, wLabelMainGraphIndex
			Duplicate/O MainGraphBIndex, wLabelMainGraphBIndex
			Duplicate/O MainGraphNBIndex, wLabelMainGraphNBIndex
			Duplicate/O MainGraphSerial0, wLabelMainGraphSerial0
			Duplicate/O MainGraphXLock, wLabelMainGraphXLock
		else
			Duplicate/O wLabelMainGraphIndex, MainGraphIndex
			Duplicate/O wLabelMainGraphBIndex, MainGraphBIndex
			Duplicate/O wLabelMainGraphNBIndex, MainGraphNBIndex
			Duplicate/O wLabelMainGraphSerial0, MainGraphSerial0
			Duplicate/O wLabelMainGraphXLock, MainGraphXLock
		endif
	SetDataFolder fldrSav0
End

Function tSort_CleartSortMainGraph()
	Variable	i = 0

	DoWindow/F tSortMainGraph
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		String WaveListInGraph = Wavelist("!MainGraphXLock", ";", "WIN:")
		do
			String sdw = StringFromList(i, WaveListInGraph)
			If(strlen(sdw)<1)
				break
			endIf
//			If(StringMatch(sdw, "MainGraphSerial0"))
//				SetDataFolder fldrSav0
//				break
//			endIf
			RemoveFromGraph/W=tSortMainGraph $sdw
			i += 1
		while(1)
	SetDataFolder fldrSav0
	i = 0
	WaveListInGraph = Wavelist("*", ";", "WIN:")
	do
		sdw = StringFromList(i, WaveListInGraph)
		If(strlen(sdw)<1)
			break
		endif
		RemoveFromGraph/W=tSortMainGraph $sdw
		i += 1
	while(1)
End

Function tSort_AutoSearch(ctrlName) : ButtonControl
	String ctrlName

	SVAR tWaveSort = root:Packages:tSort:tWaveSort
	NVAR DetectSpikeAmp = root:Packages:tSort:DetectSpikeAmp
	NVAR DetectSmoothingBox = root:Packages:tSort:DetectSmoothingBox
	NVAR DetectTightBack = root:Packages:tSort:DetectTightBack
	NVAR DetectTightness = root:Packages:tSort:DetectTightness

	String ssrcW = tWaveSort	
	Wave srcW = $ssrcW

	//PeakFindings
	ControlInfo/W=tSortMainControlPanel PopupSpikeDetect_tab2
	Variable PolarizedPA
	Switch(V_Value)
		case 2:
			PolarizedPA = -DetectSpikeAmp
			break
		default:
			PolarizedPA = DetectSpikeAmp
			break
	endSwitch
	
	If(StringMatch(ctrlName, "BtMarqueeAdd"))
		GetMarquee/W=tSortMainGraph bottom
		FindLevels/Q/B=(DetectSmoothingBox)/R=(V_left, V_right) srcW, PolarizedPA
	else
		FindLevels/Q/B=(DetectSmoothingBox) srcW, PolarizedPA
	endIf

	Wave W_FindLevels
	Wave MainGraphXLock = root:Packages:tSort:MainGraphXLock

	Variable i = 0, prenum = 0
	If(StringMatch(ctrlName, "BtMarqueeAdd"))
		For(i = 0; i < numpnts(W_FindLevels); i += 1)		
			Variable npnts = numpnts(MainGraphXLock) + 1
			If(i == 0) 
				prenum = npnts - 1
				Print prenum
			endIf
			Insertpoints npnts, 1, MainGraphXLock
			MainGraphXLock[npnts] = W_FindLevels[i]
		EndFor
	else
		prenum = 0
		Duplicate/O W_FindLevels, root:Packages:tSort:MainGraphXLock
	endIf

	Variable npnts_FLV = numpnts(W_FindLevels)

	i = 0
	do
		Variable FLI = W_FindLevels[i] - DetectTightBack *deltax(srcW)
		Variable FLF = W_FindLevels[i] + DetectTightness*deltax(srcW)
		Wavestats/Q/M=1/R=(FLI, FLF) srcW
		ControlInfo/W=tSortMainControlPanel PopupSpikeDetect_tab2
		Switch(V_Value)
			case 1:
				If(abs(V_max) > abs(DetectSpikeAmp))
					MainGraphXLock[prenum + i] = V_maxloc
				else
					MainGraphXLock[prenum + i] = NaN
				endIf
				break
			case 2:
				If(abs(V_min) > abs(DetectSpikeAmp))
					MainGraphXLock[prenum + i] = V_minloc
				else
					MainGraphXLock[prenum + i] = NaN
				endIf
				break
			case 3:
				DoAlert 0, "UnderConstruction"
				Abort
				break
			default:
				break
		endSwitch
		i += 1
		MainGraphXLock[prenum + i] = NaN
	while(i <= npnts_FLV)
	
	KillWaves W_FindLevels

	Sort MainGraphXLock, MainGraphXLock

	//同じピークを削除する
	i = 0
	do
		If(numtype(MainGraphXLock[i]) == 0)
			If(MainGraphXLock[i] == MainGraphXLock[i + 1])
				DeletePoints i, 1, MainGraphXLock
			else
				i+=1
			endIf
		else
			DeletePoints i, 1, MainGraphXLock
		endIf
	while(i< numpnts(MainGraphXLock))
//	DeletePoints (numpnts(MainGraphXLock) - 1), 1, MainGraphXLock
		
	Duplicate/O MainGraphXLock, root:Packages:tSort:MainGraphIndex
	Wave MainGraphIndex = root:Packages:tSort:MainGraphIndex
	MainGraphIndex = 0
	
	Duplicate/O MainGraphIndex, root:Packages:tSort:MainGraphSerial0
	
	tSort_CheckBurstingIEII()
	
	tSort_CopyLabelWave(1, tWaveSort)
	
	Print numpnts(MainGraphIndex), "events were detected!"
End

Function tSort_MarqueeDelete(ctrlName) : ButtonControl
	String ctrlName
	
	SVAR tWaveSort = root:Packages:tSort:tWaveSort

	String fldrsav0 = GetDataFolder(1)
	SetDatafolder root:Packages:tSort:
		Wave XLock
		Wave/T wvName
	SetDataFolder fldrsav0

	GetMarquee/W=tSortMainGraph bottom
	Variable i = 0
	Variable npnts = numpnts(XLock)
	do
		If(V_left< XLock[i] && XLock[i]<V_right && StringMatch(tWaveSort, wvName[i]))
			tSort_DeleteSpecifiedEvent(i + 1)
		endIf
		i += 1
	while(i < npnts)
End

Function tSort_DeleteSpecifiedEvent(EventSerial)
	Variable EventSerial

	String fldrsav0 = GetDataFolder(1)
		SetDataFolder root:Packages:tSort:
		String T0WL = Wavelist("*", ";", "WIN:tSortMasterTable#T0")
	SetDataFolder fldrsav0

	Variable i = 0
	String SFL = ""
	do
		SFL = StringFromList(i, T0WL)
		If(Strlen(SFL)<1)
			break
		endIf
		Deletepoints (EventSerial - 1), 1, $("root:Packages:tSort:" + SFL)
		i += 1
	while(1)
	
	Wave Serial0 = root:Packages:tSort:Serial0
	Serial0[p,] = x + 1
	
	tSort_adjustIEI()
	
	tSort_CheckBurstingIEII()
	
	tSort_UpdateMasterLb2D()
	
	ControlInfo/W=tSortMasterTable Lb0
	If(V_value <10)
		ListBox Lb0, win=tSortMasterTable, row=-1, selRow= V_value-1
	else
		ListBox Lb0, win=tSortMasterTable, row=(V_value - 10), selRow= V_value-1
	endif
	
	tSort_UpdateLableWave()
	
	tSort_ExtractEventWaves("")
end

Function tSort_adjustIEI()
	
	String fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		Wave IEI, XLock
		Wave/T wvName
	SetDataFolder fldrsav0
	
	//IEI
	ControlInfo/W=tSortMainControlPanel CheckIEI_tab3
	If(V_value == 0)
		Abort
	endIf

	IEI[0] = NaN
	
	Variable i = 1
	do
		If(StringMatch(wvName[i], wvName[i-1]))
				IEI[i] = XLock[i] - XLock[i-1]
		else
				IEI[i] = NaN
		endIf		
		i += 1
	while(i < numpnts(wvName))
end

Function tSort_SetEachParamMainGraph(ctrlName) : ButtonControl
	String ctrlName
	
	Variable ticks0, ticks1
	ticks0 = ticks
	
	PauseUpdate

	SVAR tWaveSort = root:Packages:tSort:tWaveSort
	Wave srcW = $tWaveSort

	String fldrsav0 = GetDataFolder(1)
	SetDatafolder root:Packages:tSort:
		Wave MainGraphXLock, MainGraphSerial0
		Wave Serial0, XLock, IEI, Base, Amplitude, HalfW, PC1, PC2, PC3, Index, IndexedIEI, PatternIndex
		Wave/T wvName
		String T0WL = Wavelist("*", ";", "WIN:tSortMasterTable#T0")
	SetDataFolder fldrsav0
	
	String SFL = ""

	//各ウェーブのラストにポイントを挿入。Wave名と, XLockから挿入しようとしているイベントの位置をつかみ、リストとループを用いながら、pointを挿入する。そのポイントを変数に代入。
	Variable i, j
	i = 0
	do
		FindValue/T=1.0E-5/V=(MainGraphXLock[i]) XLock
		
		If(V_Value != -1 && StringMatch(tWaveSort, wvName[i]))
			i += 1
			If(i>numpnts(MainGraphXLock))
				break
			endIf
			continue
		endIf
		
		j = 0
		Variable npnts = numpnts(Serial0)+1
		do
			SFL = StringFromList(j, T0WL)
			If(Strlen(SFL)<1)
				break
			endIf
			Insertpoints npnts, 1, $("root:Packages:tSort:" + SFL)
			j+= 1
		while(1)
		
		//wvName
		wvName[npnts] = tWaveSort
		
		//XLock
		XLock[npnts] = MainGraphXLock[i]
		
		//Base
		Base[npnts] = 0
		
		//Amplitude
		ControlInfo/W=tSortMainControlPanel CheckAmplitude_tab3
		If(V_value)
			Amplitude[npnts] = ABS(srcW(MainGraphXLock[i]) - Base[npnts])
		endIf
		
		//HalfW
		ControlInfo/W=tSortMainControlPanel CheckHalfW_tab3
		If(V_value)
			Variable HalfWBack, HalfWForward
			HalfWBack = MainGraphXLock[i]
			HalfWForward = MainGraphXLock[i] 
			Variable k = 0
			do
				HalfWBack -= deltax(srcW)
				HalfWForward += deltax(srcW)
				k += 1
			while(ABS(srcW(HalfWForward) > ABS(srcW(MainGraphXLock[i]) - Base[npnts])/2))
			HalfW[npnts] = HalfWForward - HalfWBack -deltax(srcW)
		endIf
		
		//Sorting & Serial0
		If(i != 0 && StringMatch(tWaveSort, wvName[i]) == 0 && (XLock[npnts] < XLock[npnts - 1]))
			fldrsav0 = GetDataFolder(1)
			SetDataFolder root:Packages:tSort:
				String ForSort1 = Wavelist("*", ",", "WIN:tSortMasterTable#T0")
				String ForSort2 = ForSort1[0, (Strlen(T0WL)-2)]
				String t = "Sort/A {wvName, XLock, Serial0}, " + ForSort2
				Execute t
			SetDataFolder fldrsav0
			
			FindLevel/P/Q Serial0, 0
			Variable InsertingPoint = V_LevelX
			Serial0[p,] = x + 1
		else
			InsertingPoint = npnts
			Serial0[p,] = x + 1	
		endIf
		
		MainGraphSerial0[i] = Serial0[InsertingPoint]
		
		//Sorting (Function)
//		fldrsav0 = GetDataFolder(1)
//		SetDataFolder root:Packages:tSort:
//			Sort/A {wvName, XLock, Serial0}, Serial0,wvName,XLock,IEI,Base,Amplitude,HalfW,PC1,PC2,PC3,Index,IndexedIEI,PatternIndex
//			Sort/A {wvName, XLock, Serial0}, Serial0,wvName,XLock,IEI,Base,Amplitude,HalfW,PC1,PC2,PC3,Index,IndexedIEI,PatternIndex
//		SetDataFolder fldrsav0
		
		//IEI
		ControlInfo/W=tSortMainControlPanel CheckIEI_tab3
		If(V_value)
			If(i !=0)
				If(StringMatch(wvName[InsertingPoint], wvName[InsertingPoint-1]))
					IEI[InsertingPoint] = MainGraphXLock[i] - MainGraphXLock[i-1]
				else
					IEI[InsertingPoint] = NaN
				endIf
			else
				IEI[InsertingPoint] = NaN
			endIf
		endIf
				
		i += 1
	while(i<numpnts(MainGraphXLock))

//	npnts = numpnts(Serial0)
	If(npnts <10)
		ListBox Lb0, win=tSortMasterTable, row=-1, selRow= npnts-1
	else
		ListBox Lb0, win=tSortMasterTable, row=(npnts - 10), selRow= npnts-1
	endif

	tSort_CopyLabelWave(1, tWaveSort)

	tSort_UpdateMasterLb2D()
	
	ResumeUpdate
	
	ticks1 = ticks
	Print (ticks1 - ticks0)/60, "s"
End

Function tSort_BaselineSubtraction(ssrcW)
	String ssrcW

	Wave srcW = $ssrcW
	Variable var = Mean(srcW)
	srcW -= var
End

Function tSort_UpdateMasterLb2D()
	Variable vnpnts = numpnts(root:Packages:tSort:Serial0)
	
	String fldrsav0 = GetDataFolder(1)
	SetDatafolder root:Packages:tSort:
		Wave MainGraphXLock
		Wave Serial0, XLock, IEI, Base, Amplitude, HalfW, PC1, PC2, PC3, Index, IndexedIEI, PatternIndex
		Wave/T wvName, tSortMasterLb2D
	SetDataFolder fldrsav0

	Redimension/N=(vnpnts, 16) tSortMasterLb2D
	
	//Serial0
	tSortMasterLb2D[][%Serial0]=Num2str(Serial0[p])
	
	//wvName
	tSortMasterLb2D[][%wvName]=wvName[p]
	
	//XLock
	tSortMasterLb2D[][%XLock]=Num2str(XLock[p])
	
	//IEI
	tSortMasterLb2D[][%IEI]=Num2str(IEI[p])
	
	//Base
	tSortMasterLb2D[][%Base]=Num2str(Base[p])
	
	//Amplitude
	tSortMasterLb2D[][%Amplitude]=Num2str(Amplitude[p])
	
	//HalfW
	tSortMasterLb2D[][%HalfW]=Num2str(HalfW[p])
	
	//PC1
	tSortMasterLb2D[][%PC1]=Num2str(PC1[p])
	
	//PC2
	tSortMasterLb2D[][%PC2]=Num2str(PC2[p])
	
	//PC3
	tSortMasterLb2D[][%PC3]=Num2str(PC3[p])
	
	//Index
	tSortMasterLb2D[][%Index]=Num2str(Index[p])
	
	//IndexedIEI
	tSortMasterLb2D[][%IndexedIEI]=Num2str(IndexedIEI[p])
	
	//PatternIndex
	tSortMasterLb2D[][%PatternIndex]=Num2str(PatternIndex[p])	
end

// DispMode /////////////////////////////////////////////////

Function tSort_MainGraphTransform(ctrlName) : ButtonControl
	String ctrlName

	SVAR StrWeightList = root:Packages:tSort:StrWeightList
	NVAR bitDispMode = root:Packages:tSort:bitDispMode
	NVAR SecureVal = root:Packages:tSort:MainGraphSecureVal
	NVAR SpacerVal = root:Packages:tSort:MainGraphSpacerVal
	
	Wave/T ListWave = root:Packages:tSort:tSortListWave
	ControlInfo/W=tSortMainControlPanel SortWaveList_tab0
	If(V_value < 0)
		V_value = 0
	endIf

	String StrSpikeWave = ListWave[V_value][0]
	String StrLFPWave = ListWave[V_value][1]
	String StrECoGWave = ListWave[V_value][2]
	String StrEMGWave = ListWave[V_value][3]
	String StrMarkerWave = ListWave[V_value][4]

	Wave SpikeWave = $StrSpikeWave
	Wave LFPWave = $StrLFPWave
	Wave ECoGWave = $StrECoGWave
	Wave EMGWave = $StrEMGWave
	Wave MarkerWave = $StrMarkerWave
	Wave MainGraphIndex = root:Packages:tSort:MainGraphIndex
	Wave MainGraphBIndex = root:Packages:tSort:MainGraphBIndex
	Wave MainGraphNBIndex = root:Packages:tSort:MainGraphNBIndex	
	Wave MainGraphXLock = root:Packages:tSort:MainGraphXLock

	DoWindow/F tSortMainGraph

	If(StringMatch(ctrlName, "BtMainGraphTransform_tab1"))
		tSort_RefreshMainGraph()
	endIf
		
	Variable TraceUnits = 0, i = 0
	
	for(i = 0; i < 7; i +=1)
		If(bitDispMode & 2^i)
			Variable WeightValue = str2num(StringFromList(i, StrWeightList))
			TraceUnits += WeightValue
		endIf
	endfor
	
	TraceUnits *= SecureVal
	
	Variable axisBottomRatio = 0, axisTopRatio = 0
	
	If(bitDispMode & 2^0)
		axisTopRatio = axisBottomRatio + str2num(StringFromList(0, StrWeightList))/TraceUnits
		ModifyGraph axisEnab(left) = {axisBottomRatio, axisTopRatio}
		ModifyGraph lblPos(left)=75,lblRot(left)=-90
		Label left "Spike"
		axisBottomRatio = axisTopRatio + SpacerVal
	endIf
	
	If(bitDispMode & 2^5)
		axisTopRatio =axisBottomRatio + str2num(StringFromList(5, StrWeightList))/TraceUnits
		ModifyGraph axisEnab(IndexAxis) = {axisBottomRatio, axisTopRatio}, freePos(IndexAxis)=0
		ModifyGraph noLabel(IndexAxis)=1,axThick(IndexAxis)=0,lblPos(IndexAxis)=75
		ModifyGraph lblRot(IndexAxis)=-90
		ControlInfo/W=tSortMainControlPanel Popup_IndexType_tab1
		Switch(V_value)
			case 1:
				ModifyGraph mode(MainGraphIndex)=3
				tSort_IndexMarkerType("",V_value,"")
				break
			case 2:
				ModifyGraph mode(MainGraphIndex)=3
				tSort_IndexMarkerType("",V_value,"")
				break
			default:
				break
		endSwitch
//		Wavestats/Q MainGraphIndex
//		ModifyGraph zColor(MainGraphIndex)={MainGraphIndex,*,V_max,Rainbow256,0}
		Label IndexAxis "Detection"
		axisBottomRatio = axisTopRatio + SpacerVal
	endIf
	
	If(bitDispMode & 2^6)
		axisTopRatio = axisBottomRatio + str2num(StringFromList(6, StrWeightList))/TraceUnits
		ModifyGraph axisEnab(BIndexAxis) = {axisBottomRatio+0.02, axisTopRatio-0.02}, freePos(BIndexAxis)=0
		ModifyGraph noLabel(BIndexAxis)=1,axThick(BIndexAxis)=0,lblPos(BIndexAxis)=75
		ModifyGraph lblRot(BIndexAxis)=-90
		ModifyGraph mode(MainGraphBIndex)=3
		ControlInfo/W=tSortMainControlPanel Popup_BurstType_tab1
		tSort_BurstMarkerType("",V_value,"")
		Label BIndexAxis "Burst"
		axisBottomRatio = axisTopRatio + SpacerVal
	endIf
	
	If(bitDispMode & 2^7)
		axisTopRatio = axisBottomRatio + str2num(StringFromList(7, StrWeightList))/TraceUnits
		ModifyGraph axisEnab(NBIndexAxis) = {axisBottomRatio, axisTopRatio}, freePos(NBIndexAxis)=0
		ModifyGraph noLabel(NBIndexAxis)=1,axThick(NBIndexAxis)=0,lblPos(NBIndexAxis)=75
		ModifyGraph lblRot(NBIndexAxis)=-90
		ModifyGraph mode(MainGraphNBIndex)=3
		ControlInfo/W=tSortMainControlPanel Popup_NonBurstType_tab1
		tSort_NonBurstMarkerType("",V_value,"")
		Label NBIndexAxis "NonB"
		axisBottomRatio = axisTopRatio + SpacerVal
	endIf
	
	If(bitDispMode & 2^1)
		axisTopRatio =axisBottomRatio + str2num(StringFromList(1, StrWeightList))/TraceUnits
		ModifyGraph axisEnab(LFPAxis) = {axisBottomRatio, axisTopRatio}, freePos(LFPAxis)=0
		ModifyGraph lblPos(LFPAxis)=75,lblRot(LFPAxis)=-90
		Label LFPAxis "LFP"
		axisBottomRatio = axisTopRatio + SpacerVal
	endIf
	
	If(bitDispMode & 2^2)
		axisTopRatio = axisBottomRatio + str2num(StringFromList(2, StrWeightList))/TraceUnits
		ModifyGraph axisEnab(ECoGAxis) = {axisBottomRatio, axisTopRatio}, freePos(ECoGAxis)=0
		ModifyGraph lblPos(ECoGAxis)=75,lblRot(ECoGAxis)=-90
		Label ECoGAxis "ECoG"
		axisBottomRatio = axisTopRatio + SpacerVal
	endIf
	
	If(bitDispMode & 2^3)
		axisTopRatio = axisBottomRatio + str2num(StringFromList(3, StrWeightList))/TraceUnits
		ModifyGraph axisEnab(EMGAxis) = {axisBottomRatio, axisTopRatio}, freePos(EMGAxis)=0
		ModifyGraph lblPos(EMGAxis)=75,lblRot(EMGAxis)=-90
		Label EMGAxis "EMG"
		axisBottomRatio = axisTopRatio + SpacerVal
	endIf
	
	If(bitDispMode & 2^4)
		axisTopRatio = axisBottomRatio + str2num(StringFromList(4, StrWeightList))/TraceUnits
		ModifyGraph axisEnab(MarkerAxis) = {axisBottomRatio, axisTopRatio}, freePos(MarkerAxis)=0
		ModifyGraph lblPos(MarkerAxis)=75,lblRot(MarkerAxis)=-90
		Label MarkerAxis "Marker"
	endIf
	
	tSort_MainGraphIndexColorScale("")
End

Function tSort_RefreshMainGraph()
	
	SVAR tWaveSort = root:Packages:tSort:tWaveSort
	NVAR bitDispMode = root:Packages:tSort:bitDispMode
	
	tSort_CleartSortMainGraph()
	
	Wave/T ListWave = root:Packages:tSort:tSortListWave
	ControlInfo/W=tSortMainControlPanel SortWaveList_tab0
	If(V_value < 0)
		V_value = 0
	endIf

	String StrSpikeWave = ListWave[V_value][0]
	String StrLFPWave = ListWave[V_value][1]
	String StrECoGWave = ListWave[V_value][2]
	String StrEMGWave = ListWave[V_value][3]
	String StrMarkerWave = ListWave[V_value][4]

	tWaveSort = StrSpikeWave

	Wave SpikeWave = $StrSpikeWave
	Wave LFPWave = $StrLFPWave
	Wave ECoGWave = $StrECoGWave
	Wave EMGWave = $StrEMGWave
	Wave MarkerWave = $StrMarkerWave
	Wave MainGraphIndex = root:Packages:tSort:MainGraphIndex
	Wave MainGraphBIndex = root:Packages:tSort:MainGraphBIndex
	Wave MainGraphNBIndex = root:Packages:tSort:MainGraphNBIndex	
	Wave MainGraphXLock = root:Packages:tSort:MainGraphXLock

	If(bitDispMode & 2^0)
		AppendToGraph/W=tSortMainGraph SpikeWave
	endIf

	If(bitDispMode & 2^1)
		AppendToGraph/L=LFPAxis LFPWave
	endIf

	If(bitDispMode & 2^2)
		AppendToGraph/L=ECoGAxis ECoGWave
	endIf

	If(bitDispMode & 2^3)
		AppendToGraph/L=EMGAxis EMGWave
	endIf

	If(bitDispMode & 2^4)
		AppendToGraph/L=MarkerAxis MarkerWave
	endIf
	
	If(bitDispMode & 2^5)
		AppendToGraph/L=IndexAxis MainGraphIndex vs MainGraphXLock
	endIf
		
	If(bitDispMode & 2^6)
		AppendToGraph/L=BIndexAxis MainGraphBIndex vs MainGraphXLock
	endIf
		
	If(bitDispMode & 2^7)
		AppendToGraph/L=NBIndexAxis MainGraphNBIndex vs MainGraphXLock
	endIf	
End

Function tSort_ModifiyGraphHeight(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	ModifyGraph/W = tSortMainGraph height= (28.3465*varNum)
End

Function tSort_bitDispModeoFromCheck(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	NVAR bitDispMode = root:Packages:tSort:bitDispMode
	Variable bit0, bit1, bit2, bit3, bit4, bit5, bit6, bit7
	
	ControlInfo/W=tSortMainControlPanel CheckSpike_tab1
	bit0 = V_Value
	ControlInfo/W=tSortMainControlPanel CheckLFP_tab1
	bit1 = V_Value
	ControlInfo/W=tSortMainControlPanel CheckECoG_tab1
	bit2 = V_Value
	ControlInfo/W=tSortMainControlPanel CheckEMG_tab1
	bit3 = V_Value
	ControlInfo/W=tSortMainControlPanel CheckMarker_tab1
	bit4 = V_Value
	ControlInfo/W=tSortMainControlPanel CheckIndex_tab1
	bit5 = V_Value	
	ControlInfo/W=tSortMainControlPanel CheckBurstIndex_tab1
	bit6 = V_Value
	ControlInfo/W=tSortMainControlPanel CheckNonBurstIndex_tab1
	bit7 = V_Value

	bitDispMode = tSort_BitEncoder(bit0, bit1, bit2, bit3, bit4, bit5, bit6, bit7)
End

Function tSort_IndexMarkerType(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	NVAR bitDispMode = root:Packages:tSort:bitDispMode
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		Wave Serial0, Index, MainGraphIndex, MainGraphXLock
		Variable IndexMax=Wavemax(Index)
		
		DoWindow/F tSortMainGraph
		
		If(bitDispMode & 2^5)
			Switch (popNum)
				case 1:
					ModifyGraph textMarker(MainGraphIndex)=0
					ModifyGraph mode(MainGraphIndex)=3, marker(MainGraphIndex)=10
					break
				case 2:
					If(numpnts(Serial0) < 1)
						SetDataFolder fldrSav0
						Abort
					endIf
					ModifyGraph textMarker(MainGraphIndex)={MainGraphSerial0,"default",0,90,5,0.00,0.00}
					break
				default:
					break
			endSwitch
		endIf
	SetDataFolder fldrSav0
End

Function tSort_BurstMarkerType(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	NVAR bitDispMode = root:Packages:tSort:bitDispMode
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		Wave MainGraphBIndex

		DoWindow/F tSortMainGraph
		
		If(bitDispMode & 2^6)
			ModifyGraph marker(MainGraphBIndex)=(popNum - 1)
		endIf
	SetDataFolder fldrSav0
End

Function tSort_NonBurstMarkerType(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	NVAR bitDispMode = root:Packages:tSort:bitDispMode
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		Wave MainGraphBIndex

		DoWindow/F tSortMainGraph
		
		If(bitDispMode & 2^7)
			ModifyGraph marker(MainGraphNBIndex)=(popNum - 1)
		endIf
	SetDataFolder fldrSav0
	SetDataFolder fldrSav0
End

// Extract/////////////////////////////////////////////////

Function tSort_AmpSD(ctrlName) : ButtonControl
	String ctrlName

	SVAR tWaveSort = root:Packages:tSort:tWaveSort
	NVAR DetectSpikeAmp = root:Packages:tSort:DetectSpikeAmp
	NVAR DetectSpikeSD = root:Packages:tSort:DetectSpikeSD

	WaveStats/Q $tWaveSort
	DetectSpikeAmp = DetectSpikeSD * V_sdev
End

// Clustering/////////////////////////////////////////////////

Function tSort_PCA(ctrlName) : ButtonControl
	String ctrlName
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		
		Wave PC1, PC2, PC3
		String EventWaveList = WaveList("Event_*", ";","")
		Concatenate/O EventWaveList, EventMatrix
		
		PCA/ALL/SRMT/SCMT EventMatrix
		Wave M_C
		
		PC1[]=M_C[0][p]
		PC2[]=M_C[1][p]
		PC3[]=M_C[2][p]
	
	SetDataFolder fldrSav0
	
	tSort_UpdateMasterLb2D()
End

Function tSort_FPCluster(ctrlName) : ButtonControl
	String ctrlName
	
	Variable maxClusters=10
	Prompt maxClusters, "Maximum Number of FP Clusters"
	DoPrompt "Clustering", maxclusters
	PauseUpdate; Silent 1
	
	if (V_Flag)
		return -1								// User canceled
	endif
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		Wave PC1, PC2, PC3
		ColorTab2Wave Rainbow256
		
		WMXYZToXYZTriplet(PC1,PC2,PC3, "xyzPC")
		
		FPClustering/NOR/CM/MAXC=(maxClusters) xyzPC
		
		Wave M_colors, W_FPClusterIndex, Index
		
		Index = W_FPClusterIndex		
		
		Duplicate/O W_FPClusterIndex W_FPClusterIndex_Sorted
		WMXYZTripletToXYZWaves(xyzPC,"PC1_Sorted", "PC2_Sorted", "PC3_Sorted")
		Sort W_FPClusterIndex_Sorted, PC1_Sorted, PC2_Sorted, PC3_Sorted, W_FPClusterIndex_Sorted
		
		Variable boundary3, boundary4, j=Wavemax(W_FPClusterIndex), numClassesFP=Wavemax(W_FPClusterIndex)
		Variable cIndexFP=round(DimSize(M_colors,0)/numClassesFP)
		
		Execute "NewGizmo/T=\"Principal Components - FP\""
		Execute "MoveWindow 540.75,41.75,1069.5,521.75"
		Execute "ModifyGizmo setDisplayList=0, opName=clearColor, operation=clearColor, data={0.398,0.398,0.398,0}"
		Execute "ModifyGizmo euler={25,-25,0}"
		Display/W=(35.25,41.75,524.25,522.5) as "FP Clustering Results"
		
		do
	
			boundary3=BinarySearch(W_FPClusterIndex_Sorted,j)
			boundary4=BinarySearch(W_FPClusterIndex_Sorted,(j-1))
		
			Duplicate/O/R=[boundary4+1,boundary3] W_FPClusterIndex_Sorted, $("W_FPClusterIndex_"+ num2str(j))
			Duplicate/O/R=[boundary4+1,boundary3] PC1_Sorted $("PC1_"+ num2str(j))
			Duplicate/O/R=[boundary4+1,boundary3] PC2_Sorted $("PC2_"+ num2str(j))
			Duplicate/O/R=[boundary4+1,boundary3] PC3_Sorted $("PC3_"+ num2str(j))
			WMXYZToXYZTriplet($("PC1_"+ num2str(j)),$("PC2_"+ num2str(j)),$("PC3_"+ num2str(j)), ("xyzPC"+num2str(j)))
			string/G temp="xyzPC"+num2str(j)
			string/G scatNum="scatter"+(num2str((Wavemax(W_FPClusterIndex)-j)))
			string/G cFrac
			//Wave M_colors
			//sprintf cFrac,"ModifyGizmo ModifyObject=%s, property={color,%g,%g,%g,0}", scatNum, abs(enoise(1)),abs(enoise(1)),abs(enoise(1))
			//sprintf cFrac,"ModifyGizmo ModifyObject=%s, property={color,%g,%g,%g,0}", scatNum, M_colors[round((256/numClassesFP))*j][0],M_colors[round((256/numClassesFP))*j][1],M_colors[round((256/numClassesFP))*j][2]
			sprintf cFrac,"ModifyGizmo ModifyObject=%s, property={color,%g,%g,%g,0}", scatNum, (M_colors[cIndexFP*j][0])/65535,(M_colors[cIndexFP*j][1])/65535,(M_colors[cIndexFP*j][2])/65535
			Execute "AppendToGizmo nextscatter=$temp"
			Execute "ModifyGizmo ModifyObject=$scatNum property={shape,1}"
			Execute "ModifyGizmo ModifyObject=$scatNum property={size,3}"			
			Execute cFrac
			Execute "ModifyGizmo showAxisCue = 1"
			Extract/O XLock, $("XLock"+num2Str(j)), W_FPClusterIndex==j
			Make/O/N=(numPnts($("XLock"+num2Str(j)))) $("SpkIndex"+num2Str(j))=j
			AppendToGraph/L=L_spike/C=(M_colors[cIndexFP*j][0],M_colors[cIndexFP*j][1],M_colors[cIndexFP*j][2]) $("SpkIndex"+num2Str(j)) vs $("XLock"+num2Str(j))
			ModifyGraph mode($("SpkIndex"+num2Str(j)))=3,marker($("SpkIndex"+num2Str(j)))=10,msize($("SpkIndex"+num2Str(j)))=5
			//Execute "ModifyGizmo ModifyObject=$scatNum property={color,0,0,0,0}"
			KillStrings temp, scatnum, cFrac
			
			Variable k=0   //begin Addition for Overlayed spikes
			string/G spkList=WaveList("Event_*",";","")
			
				do
						if (W_FPClusterIndex[k]==j)
							AppendToGraph/T/C=(M_colors[cIndexFP*j][0],M_colors[cIndexFP*j][1],M_colors[cIndexFP*j][2]) $(StringFromList(k,spkList))
						endif
					k+=1
				while (k<numPnts(W_FPClusterIndex))	// end Addition for Overlayed Spikes
			
			j-=1
	
		while (j>=0)
		
		ModifyGraph axisEnab(L_spike)={0,0.4},freePos(L_spike)=0
		ModifyGraph axisEnab(left)={0.6,1}
		ModifyGraph lblPos(L_spike)=50;DelayUpdate
		Label L_spike "Unit Number"
		Label bottom "Time (s)"
		ModifyGraph lblPos(left)=50;DelayUpdate
		Label left "Voltage"
		Label top "Time (ms)\\u#2"
		SetAxis bottom 0,*
		ModifyGraph axOffset(top)=2
		ModifyGraph lblMargin(top)=25,lblLatPos=0
		SetDrawEnv fsize= 18;DelayUpdate
		DrawText -.01,-0.125,"Spike Waveforms"
		SetDrawEnv fsize= 18;DelayUpdate
		DrawText -.01,0.545,"Spike Times"
		ModifyGraph wbRGB=(56576,56576,56576),gbRGB=(56576,56576,56576)
		SetDrawLayer UserBack
		SetDrawEnv linethick= 0,fillfgc= (0,0,0)
		DrawRect 0,0.579281183932347,1.00191938579655,1.01902748414376
		SetDrawEnv linethick= 0,fillfgc= (0,0,0)
		DrawRect 0,-0.0169133192389006,1.00191938579655,0.422832980972516
		SetDrawLayer UserFront
		KillStrings spkList
		
	SetDataFolder fldrSav0
	
	tSort_CheckBurstingIEII()
	
	tSort_UpdateMasterLb2D()
	
	tSort_RenewEachMainGraphIndex()
	
	tSort_MainGraphIndexColorScale("")
End

Function tSort_FPClusterMin(ctrlName) : ButtonControl
	String ctrlName
	
	Variable maxClusters=10
	Prompt maxClusters, "Maximum Number of FP Clusters"
	DoPrompt "Clustering", maxclusters
	PauseUpdate; Silent 1
	
	if (V_Flag)
		return -1								// User canceled
	endif
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		Wave PC1, PC2, PC3
		
		WMXYZToXYZTriplet(PC1,PC2,PC3, "xyzPC")
		
		FPClustering/NOR/CM/MAXC=(maxClusters) xyzPC
		
		Wave W_FPClusterIndex, Index
		
		Index = W_FPClusterIndex		
	SetDataFolder fldrSav0
	
	tSort_CheckBurstingIEII()
	
	tSort_UpdateMasterLb2D()
	
	tSort_RenewEachMainGraphIndex()
	
	tSort_MainGraphIndexColorScale("")
End


Function tSort_KMeansCluster(ctrlName) : ButtonControl
	String ctrlName
	
	Variable numClassesKM=3
	Prompt numClassesKM, "Number of  Classes for KMeans"
	DoPrompt "Clustering", numClassesKM
	PauseUpdate; Silent 1
	
	if (V_Flag)
		return -1								// User canceled
	endif
	
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		Wave PC1, PC2, PC3
		ColorTab2Wave Rainbow256

		WMXYZToXYZTriplet(PC1,PC2,PC3, "xyzPC")
		
		Duplicate/O xyzPC xyzPC4KM
		MatrixTranspose xyzPC4KM
		
		KMeans/init=3/out=2/ter=1/dead=2/ncls=(numClassesKM) xyzPC4KM

		Wave M_colors
		Wave W_KMMembers
		
		Duplicate/O W_KMMembers W_KMMembers_Sorted
		WMXYZTripletToXYZWaves(xyzPC,"PC1_Sorted", "PC2_Sorted", "PC3_Sorted")
		Sort W_KMMembers_Sorted, PC1_Sorted, PC2_Sorted, PC3_Sorted, W_KMMembers_Sorted
		
	
		Variable boundary1, boundary2, i=numClassesKM
		Variable cIndexKM=round(DimSize(M_colors,0)/numClassesKM)
	
		//Execute "NewGizmo"
		Execute "NewGizmo/T=\"Principal Components - KMeans\""
		Execute "MoveWindow 540.75,41.75,1069.5,521.75"
		Execute "ModifyGizmo setDisplayList=0, opName=clearColor, operation=clearColor, data={0.398,0.398,0.398,0}"
		Execute "ModifyGizmo euler={25,-25,0}"
		Display/W=(35.25,41.75,524.25,522.5) as "KMeans Clustering Results"
	
		do		
			boundary1=BinarySearch(W_KMMembers_Sorted,(i-1))
			boundary2=BinarySearch(W_KMMembers_Sorted,(i-2))
	
			Duplicate/O/R=[boundary2+1,boundary1] W_KMMembers_Sorted, $("W_KMMembers_"+ num2str(i))
			Duplicate/O/R=[boundary2+1,boundary1] PC1_Sorted $("PC1_"+ num2str(i))
			Duplicate/O/R=[boundary2+1,boundary1] PC2_Sorted $("PC2_"+ num2str(i))
			Duplicate/O/R=[boundary2+1,boundary1] PC3_Sorted $("PC3_"+ num2str(i))
			WMXYZToXYZTriplet($("PC1_"+ num2str(i)),$("PC2_"+ num2str(i)),$("PC3_"+ num2str(i)), ("xyzPC"+num2str(i)))
			string/G temp="xyzPC"+num2str(i)
			string/G scatNum="scatter"+(num2str((numClassesKM-i)))
			string/G cFrac
			sprintf cFrac,"ModifyGizmo ModifyObject=%s, property={color,%g,%g,%g,0}", scatNum, (M_colors[cIndexKM*i][0])/65535,(M_colors[cIndexKM*i][1])/65535,(M_colors[cIndexKM*i][2])/65535
			Execute "AppendToGizmo nextscatter=$temp"
			Execute "ModifyGizmo ModifyObject=$scatNum property={shape,1}"
			Execute "ModifyGizmo ModifyObject=$scatNum property={size,3}"
			Execute cFrac
			Execute "ModifyGizmo showAxisCue = 1"
			Extract/O XLock, $("XLock"+num2Str(i)), W_KMMembers==i
			Make/O/N=(numPnts($("XLock"+num2Str(i)))) $("SpkIndex"+num2Str(i))=i
			AppendToGraph/L=L_spike/C=(M_colors[cIndexKM*i][0],M_colors[cIndexKM*i][1],M_colors[cIndexKM*i][2]) $("SpkIndex"+num2Str(i)) vs $("XLock"+num2Str(i))
			ModifyGraph mode($("SpkIndex"+num2Str(i)))=3,marker($("SpkIndex"+num2Str(i)))=10,msize($("SpkIndex"+num2Str(i)))=5
			KillStrings temp, scatnum, cFrac
			
		
			Variable m=0   //begin Addition for Overlayed spikes
			string/G spkList=WaveList("Event_*",";","")
			
				do
						if (W_KMMembers[m]==i)
							AppendToGraph/T/C=(M_colors[cIndexKM*i][0],M_colors[cIndexKM*i][1],M_colors[cIndexKM*i][2]) $(StringFromList(m,spkList))
						endif
					m+=1
				while (m<numPnts(W_KMMembers))	// end Addition for Overlayed Spikes
				
			i-=1
	
		while (i<=0)
		
		ModifyGraph axisEnab(L_spike)={0,0.4},freePos(L_spike)=0
		ModifyGraph axisEnab(left)={0.6,1}
		ModifyGraph lblPos(L_spike)=50;DelayUpdate
		Label L_spike "Unit Number"
		Label bottom "Time (s)"
		ModifyGraph lblPos(left)=50;DelayUpdate
		Label left "Voltage"
		Label top "Time (ms)\\u#2"
		SetAxis bottom 0,*
		ModifyGraph axOffset(top)=2
		ModifyGraph lblMargin(top)=25,lblLatPos=0
		SetDrawEnv fsize= 18;DelayUpdate
		DrawText -.01,-0.125,"Spike Waveforms"
		SetDrawEnv fsize= 18;DelayUpdate
		DrawText -.01,0.545,"Spike Times"
		ModifyGraph wbRGB=(56576,56576,56576),gbRGB=(56576,56576,56576)
		SetDrawLayer UserBack
		SetDrawEnv linethick= 0,fillfgc= (0,0,0)
		DrawRect 0,0.579281183932347,1.00191938579655,1.01902748414376
		SetDrawEnv linethick= 0,fillfgc= (0,0,0)
		DrawRect 0,-0.0169133192389006,1.00191938579655,0.422832980972516
		SetDrawLayer UserFront
		KillStrings spkList
		
	SetDataFolder fldrSav0
	
	tSort_CheckBurstingIEII()
	
	tSort_UpdateMasterLb2D()
	
	tSort_RenewEachMainGraphIndex()
	
	tSort_MainGraphIndexColorScale("")
End

Function tSort_KMeansClusterMin(ctrlName) : ButtonControl
	String ctrlName
	
	Variable numClassesKM=3
	Prompt numClassesKM, "Number of  Classes for KMeans"
	DoPrompt "Clustering", numClassesKM
	PauseUpdate; Silent 1
	
	if (V_Flag)
		return -1								// User canceled
	endif
	
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		Wave PC1, PC2, PC3
		WMXYZToXYZTriplet(PC1,PC2,PC3, "xyzPC")
		
	SetDataFolder fldrSav0
	
	tSort_CheckBurstingIEII()
	
	tSort_UpdateMasterLb2D()
	
	tSort_RenewEachMainGraphIndex()
	
	tSort_MainGraphIndexColorScale("")
End

Function tSort_RenewEachMainGraphIndex()
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		Wave/T wvName
		Wave XLock, Index
		
		String IndexList = WaveList("*_MGIndex", ";", "")
		String XLockList = WaveList("*_MGXLock", ";", "")
		
		Variable i, j
		
		i = 0
		
		do
			String SFLIndex = StringFromList(i, IndexList)
			String SFLXLock = StringFromList(i, XLockList)
			If(strlen(SFLIndex) < 1)
				break
			endIf
			
			Wave EachIndex = $SFLIndex
			Wave EachXLock = $SFLXLock
			
			Redimension/n = 0 $SFLIndex, $SFLXLock
			
			String strwave
			strwave = SFLIndex[0, strsearch(SFLIndex, "_MG", 0) - 1]
			
			j = 0
			 
			do
				If(StringMatch(wvName[j], strwave))
					Variable npnts = numpnts(EachIndex)
					InsertPoints npnts, 1, EachIndex, EachXLock
					EachIndex[npnts] = Index[j]
					EachXLock[npnts] = XLock[j]
				endIf
				j += 1
			while(j < numpnts(Index))
			 
			i += 1
		while(1)
	SetDataFolder fldrSav0
end

Function tSort_CheckBurstingIEII()
	ControlInfo/W=tSortMainControlPanel CheckBurstingIEI_tab4
	If(V_Value == 0)
		return 0
	endIf
	
	String fldrsav0 = GetDataFolder(1)
	SetDatafolder root:Packages:tSort:
		Wave IEI, Index
		Wave/T wvName
	SetDatafolder fldrsav0
	
	NVAR BurstingIEI = root:Packages:tSort:BurstingIEI
	Variable i = 1
	
	For(i = 1; i < numpnts(wvName); i += 1)
		If(IEI[i] < BurstingIEI && StringMatch(wvName[i], wvName[i - 1]))
			Index[i] = Index[i - 1]
		endIf
	endFor
End

////  Hist  ///////////////////////////////////////////

Function tSort_SlaveTablePrep(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/F tSortSlaveTable
	
	String fldrsav0 = GetDataFolder(1)
	SetDatafolder root:Packages:tSort:
	Variable labelnum = 0

	ControlInfo/W=tSortMainControlPanel CheckSerial1_tab3
	If(V_value)
		If(Exists("Serial1") != 1)
			Make/N=0 Serial1
		endif
		AppendToTable/W=tSortSlaveTable#T0 Serial1
		SetDimLabel 1,labelnum,Serial1,tSortSlaveLb2D
		labelnum += 1
	endIf

	ControlInfo/W=tSortMainControlPanel CheckwvNameSlave_tab3
	If(V_value)
		If(Exists("wvNameSlave") != 1)
			Make/T/N=0 wvNameSlave
		endIf
		AppendToTable/W=tSortSlaveTable#T0 wvNameSlave
		SetDimLabel 1, labelnum,wvNameSlave, tSortSlaveLb2D
		labelnum += 1
	endIf

	ControlInfo/W=tSortMainControlPanel CheckTimeLocked_tab3
	If(V_value)
		If(Exists("TimeLocked") != 1)
			Make/N=0 TimeLocked
		endif
		AppendToTable/W=tSortSlaveTable#T0 TimeLocked
		SetDimLabel 1,labelnum,TimeLocked,tSortSlaveLb2D
		labelnum += 1
	endIf
	
	ControlInfo/W=tSortMainControlPanel CheckTrial_tab3
	If(V_value)
		If(Exists("Trial") != 1)
			Make/N=0 Trial
		endif
		AppendToTable/W=tSortSlaveTable#T0 Trial
		SetDimLabel 1,labelnum,Trial,tSortSlaveLb2D
		labelnum += 1
	endIf

	ControlInfo/W=tSortMainControlPanel CheckIndexSlave_tab3
	If(V_value)
		If(Exists("IndexSlave") != 1)
			Make/N=0 IndexSlave
		endif
		AppendToTable/W=tSortSlaveTable#T0 IndexSlave
		SetDimLabel 1,labelnum,IndexSlave,tSortSlaveLb2D
		labelnum += 1
	endIf

	ControlInfo/W=tSortMainControlPanel CheckPIndexSlave_tab3
	If(V_value)
		If(Exists("PatternIndexSlave") != 1)
			Make/N=0 PatternIndexSlave
		endif
		AppendToTable/W=tSortSlaveTable#T0 PatternIndexSlave
		SetDimLabel 1,labelnum,PatternIndex,tSortSlaveLb2D
		labelnum += 1
	endIf
	
	ControlInfo/W=tSortMainControlPanel CheckBIndexSlave_tab3
	If(V_value)
		If(Exists("BurstIndex") != 1)
			Make/N=0 BurstIndexSlave
		endif
		AppendToTable/W=tSortSlaveTable#T0 BurstIndexSlave
		SetDimLabel 1,labelnum,BurstIndex,tSortSlaveLb2D
		labelnum += 1
	endIf

	ControlInfo/W=tSortMainControlPanel CheckNBIndexSlave_tab3
	If(V_value)
		If(Exists("NonBurstIndexSlave") != 1)
			Make/N=0 NonBurstIndexSlave
		endif
		AppendToTable/W=tSortSlaveTable#T0 NonBurstIndexSlave
		SetDimLabel 1,labelnum,NonBurstIndex,tSortSlaveLb2D
		labelnum += 1
	endIf

	ControlInfo/W=tSortMainControlPanel CheckSerialRef_tab3
	If(V_value)
		If(Exists("SerialRef") != 1)
			Make/N=0 SerialRef
		endif
		AppendToTable/W=tSortSlaveTable#T0 SerialRef
		SetDimLabel 1,labelnum,SerialRef,tSortSlaveLb2D
		labelnum += 1
	endIf

	ControlInfo/W=tSortMainControlPanel CheckTrigger_tab3
	If(V_value)
		If(Exists("Trigger") != 1)
			Make/N=0 Trigger
		endif
		AppendToTable/W=tSortSlaveTable#T0 Trigger
		SetDimLabel 1,labelnum,Trigger,tSortSlaveLb2D
		labelnum += 1
	endIf

	Redimension/N=(0,14) tSortSlaveLb2D
	SetDataFolder fldrsav0
end

Function tSort_AutoHistSearch(ctrlName) : ButtonControl
	String ctrlName
	
	ControlInfo/W=tSortMainControlPanel PopupHistAnalysisMode_tab5
	Switch(V_value)
		case 1:
			tSort_HistSearchPSTH()
			break
		case 2:
			tSort_HistSearchSponta()
			break
		default:
			break
	endSwitch
end	

Function tSort_HistSearchPSTH()
	NVAR HistTrial = root:Packages:tSort:HistTrial
	NVAR HistCumTrial = root:Packages:tSort:HistCumTrial
	NVAR HistMarkerThreshold = root:Packages:tSort:HistMarkerThreshold
	
	HistTrial = 0
	
	Wave/T ListWave = root:Packages:tSort:tSortListWave
	ControlInfo/W=tSortMainControlPanel SortWaveList_tab0
	String StrMarkerWave = ListWave[V_value][4]
	Wave MarkerWave = $StrMarkerWave

	FindLevels/EDGE=1 MarkerWave, HistMarkerThreshold
	Wave W_FindLevels
	If(V_Flag == 2)
		KillWaves W_FindLevels
		Abort
	endIf
	
	HistCumTrial += V_LevelsFound
	
	Variable i = 0
	do
		Variable TrigTime = W_FindLevels[i]	
		tSort_HistPSTH(TrigTime, HistTrial)
		i += 1
		HistTrial += 1
	while(i < numpnts(W_FindLevels))

	KillWaves W_FindLevels
end

Function tSort_ManualHistSearch(ctrlName) : ButtonControl
	String ctrlName

	NVAR HistTrial = root:Packages:tSort:HistTrial
	NVAR HistCumTrial = root:Packages:tSort:HistCumTrial
	NVAR HistMarkerThreshold = root:Packages:tSort:HistMarkerThreshold

	Wave/T ListWave = root:Packages:tSort:tSortListWave
	ControlInfo/W=tSortMainControlPanel SortWaveList_tab0
	String StrMarkerWave = ListWave[V_value][2]
	Wave MarkerWave = $StrMarkerWave
	
	GetMarquee/W=tSortMainGraph/K bottom
	

	FindLevels/EDGE=1 MarkerWave, HistMarkerThreshold
	Wave W_FindLevels
	If(V_Flag == 2)
		KillWaves W_FindLevels
		Abort
	else
		Variable TrigTime = W_FindLevels[0]	
	endIf
	
	HistCumTrial += V_LevelsFound
		
	tSort_HistPSTH(TrigTime, HistTrial)
	
	HistTrial += 1
End

Function tSort_HistPSTH(TrigTime, HistTrial)
	Variable TrigTime, HistTrial

	SVAR tWaveSort = root:Packages:tSort:tWaveSort
	NVAR TimeWindow = root:Packages:tSort:HistTimeWindow
		
	Variable initialX = TrigTime - 0.5*TimeWindow
	Variable endX = TrigTime + 0.5*TimeWindow
	
	Wave srcW = $tWaveSort

	String fldrsav0 = GetDataFolder(1)
	SetDatafolder root:Packages:tSort:
		Wave MainGraphXLock
		Wave Serial0, XLock, Index,  PatternIndex
		Wave/T wvName
		Wave Serial1, Trial, TimeLocked, IndexSlave, PatternIndexSlave, SerialRef, Trigger
		Wave/T wvNameSlave
		String SlaveT0WL = Wavelist("*", ";", "WIN:tSortSlaveTable#T0")
	SetDataFolder fldrsav0
	
	String SFL = ""	
	Variable i, j
	i = 0	
	do
		If(StringMatch(wvName[i], tWaveSort))
			If(initialX<XLock[i] && XLock[i]<endX)
				j = 0
				Variable npnts = numpnts(Serial1)+1
				do
					SFL = StringFromList(j, SlaveT0WL)
					If(Strlen(SFL)<1)
						break
					endIf
					Insertpoints npnts, 1, $("root:Packages:tSort:" + SFL)
					j += 1
				while(1)
				
				wvNameSlave[npnts] = tWaveSort
				
				TimeLocked[npnts] = XLock[i] - TrigTime
				
				Trigger[npnts] = TrigTime
				
				ControlInfo/W=tSortMainControlPanel CheckTrial_tab3
				If(V_value)
					Trial[npnts] = HistTrial
				endIf
				
				ControlInfo/W=tSortMainControlPanel CheckIndexSlave_tab3
				If(V_value)
					IndexSlave[npnts] = Index[i]
				endIf
				
				ControlInfo/W=tSortMainControlPanel CheckPIndexSlave_tab3
				If(V_value)
					PatternIndexSlave[npnts] = PatternIndex[i]
				endIf
				
				ControlInfo/W=tSortMainControlPanel CheckSerialRef_tab3
				If(V_value)
					SerialRef[npnts] = Serial0[i]
				endIf
			endIf
		endIf
		i += 1
	while(i < numpnts(Serial0))
	
	tSort_SortSlaveTable()

	FindLevel/P/Q Serial1, 0
	Variable InsertingPoint = V_LevelX
	Serial1[p,] = x + 1
	
	tSort_ControlSlaveTableLb0(numpnts(Serial1))
	
	tSort_UpdateSlaveLb2D()
end

Function tSort_SortSlaveTable()
	String fldrsav0 = GetDataFolder(1)
	SetDatafolder root:Packages:tSort:
		String SlaveT0WL = Wavelist("*", ";", "WIN:tSortSlaveTable#T0")
		String ForSort1 = Wavelist("*", ",", "WIN:tSortSlaveTable#T0")
		String ForSort2 = ForSort1[0, (Strlen(SlaveT0WL)-1)]
		String t = "Sort/A {wvNameSlave, Trial, TimeLocked}, " + ForSort2
		Execute t
	SetDataFolder fldrsav0
end

Function tSort_ControlSlaveTableLb0(npnts)
	Variable npnts
	
	If(npnts <10)
		ListBox Lb0, win=tSortSlaveTable, row=-1, selRow= npnts-1
	else
		ListBox Lb0, win=tSortSlaveTable, row=(npnts - 10), selRow= npnts-1
	endif
end

Function tSort_HistSearchSponta()
	SVAR tWaveSort = root:Packages:tSort:tWaveSort
	Wave srcW = $tWaveSort
	
	String fldrsav0 = GetDataFolder(1)
	SetDatafolder root:Packages:tSort:
		Wave MainGraphXLock
		Wave Serial0, XLock, Index, PatternIndex
		Wave/T wvName
		Wave Serial1, Trial, TimeLocked, IndexSlave, PatternIndexSlave, SerialRef, Trigger
		Wave/T wvNameSlave
		String SlaveT0WL = Wavelist("*", ";", "WIN:tSortSlaveTable#T0")
	SetDataFolder fldrsav0
	
	String SFL = ""
	Variable i, j
	i = 0	
	do
		If(StringMatch(wvName[i], tWaveSort))
			j = 0
			Variable npnts = numpnts(Serial1)+1
			do
				SFL = StringFromList(j, SlaveT0WL)
				If(Strlen(SFL)<1)
					break
				endIf
				Insertpoints npnts, 1, $("root:Packages:tSort:" + SFL)
				j += 1
			while(1)
			
			wvNameSlave[npnts] = tWaveSort
			
			TimeLocked[npnts] = XLock[i]
			
			Trigger[npnts] = nan
			
			ControlInfo/W=tSortMainControlPanel CheckTrial_tab3
			If(V_value)
				Trial[npnts] = -1
			endIf
			
			ControlInfo/W=tSortMainControlPanel CheckIndexSlave_tab3
			If(V_value)
				IndexSlave[npnts] = Index[i]
			endIf

			ControlInfo/W=tSortMainControlPanel CheckPIndexSlave_tab3
			If(V_value)
				PatternIndexSlave[npnts] = PatternIndex[i]
			endIf
			
			ControlInfo/W=tSortMainControlPanel CheckSerialRef_tab3
			If(V_value)
				SerialRef[npnts] = Serial0[i]
			endIf
		endIf
		i += 1
	while(i < numpnts(Serial0))
	
	tSort_SortSlaveTable()
	
	FindLevel/P/Q Serial1, 0
	Variable InsertingPoint = V_LevelX
	Serial1[p,] = x + 1

	tSort_ControlSlaveTableLb0(numpnts(Serial1))
	
	tSort_UpdateSlaveLb2D()
end

Function tSort_HistRaster(ctrlName) : ButtonControl
	String ctrlName
	
	ControlInfo/W=tSortMainControlPanel PopupHistAnalysisMode_tab5
	Switch(V_value)
		case 1:
			tSort_HistRasterPSTH()
			break
		case 2:
			tSort_HistRasterSponta()
			break
		default:
			break
	endSwitch
end	

Function tSort_HistRasterPSTH()
	String fldrsav0 = GetDataFolder(1)
	SetDatafolder root:Packages:tSort:
		Wave Serial1, Trial, TimeLocked, IndexSlave, BurstIndexSlave, NonBurstIndexSlave
		Wave/T wvNameSlave, tSortListWave
		String SlaveT0WL = Wavelist("*", ";", "WIN:tSortSlaveTable#T0")
		String ForSort1 = Wavelist("*", ",", "WIN:tSortSlaveTable#T0")
		String ForSort2 = ForSort1[0, (Strlen(SlaveT0WL)-1)]
		String t = "Sort/A {IndexSlave, wvNameSlave, Trial, TimeLocked}, " + ForSort2
		Execute t
	SetDataFolder fldrsav0
	
	Variable i
	i = 0
	do
		If(Trial[i]<0)
			i += 1
			If(i > numpnts(wvNameSlave))
				break
			endIf
			continue
		endif

		String StrAllIndex = "IndexAll_PSTH"
		Switch(Exists(StrAllIndex))
			case 0:
				Make/n=1 $StrAllIndex
				Wave AllIndex = $StrAllIndex
				AllIndex[0] = TimeLocked[i]
				break
			case 1:
				Variable npnts = numpnts(AllIndex)
				Insertpoints npnts, 1, AllIndex
				AllIndex[npnts] = TimeLocked[i]
				break
			default:
				break
		endSwitch
		
		String StrDestWave0 = "Index"+Num2str(IndexSlave[i])+"_"+wvNameSlave[i]+"_Trial"+Num2str(Trial[i])
		Switch(Exists(StrDestWave0))
			case 0:
				Make/n=1 $StrDestWave0
				Wave DestWave0 = $StrDestWave0
				DestWave0[0] = TimeLocked[i]
				break
			case 1:
				npnts = numpnts(DestWave0)
				Insertpoints npnts, 1, DestWave0
				DestWave0[npnts] = TimeLocked[i]
				break
			default:
				break
		endSwitch

		String StrDestWave1 = "BIndex"+Num2str(IndexSlave[i])+"_"+wvNameSlave[i]+"_Trial"+Num2str(Trial[i])
		Switch(Exists(StrDestWave1))
			case 0:
				Make/n=1 $StrDestWave1
				Wave DestWave1 = $StrDestWave1
				If(numtype(BurstIndexSlave[i]) != 2)
					DestWave1[0] = TimeLocked[i]
				endIf
				break
			case 1:
				Wave DestWave1 = $StrDestWave1
				npnts = numpnts(DestWave1)
				If(numtype(BurstIndexSlave[i]) != 2)
					Insertpoints npnts, 1, DestWave1
					DestWave1[npnts] = TimeLocked[i]
				endIf
				break
			default:
				break
		endSwitch
		
		String StrDestWave2 = "NBIndex"+Num2str(IndexSlave[i])+"_"+wvNameSlave[i]+"_Trial"+Num2str(Trial[i])
		Switch(Exists(StrDestWave2))
			case 0:
				Make/n=1 $StrDestWave2
				Wave DestWave2 = $StrDestWave2
				If(numtype(NonBurstIndexSlave[i]) != 2)
					DestWave2[0] = TimeLocked[i]
				endIf
				break
			case 1:
				Wave DestWave2 = $StrDestWave2
				npnts = numpnts(DestWave2)
				If(numtype(NonBurstIndexSlave[i]) != 2)
					Insertpoints npnts, 1, DestWave2
					DestWave2[npnts] = TimeLocked[i]
				endIf
				break
			default:
				break
		endSwitch

		i += 1
	while(i <numpnts(wvNameSlave))
	
	tSort_SortSlaveTable()
	
	tSort_ConnentRaster()
End

Function tSort_ConnentRaster()
	String fldrsav0 = GetDataFolder(1)
	SetDatafolder root:Packages:tSort:
		Wave Serial1, Trial, TimeLocked
		Wave/T wvNameSlave, tSortListWave
		String SlaveT0WL = Wavelist("*", ";", "WIN:tSortSlaveTable#T0")
		String ForSort1 = Wavelist("*", ",", "WIN:tSortSlaveTable#T0")
		String ForSort2 = ForSort1[0, (Strlen(SlaveT0WL)-1)]
		String t = "Sort/A {IndexSlave, wvNameSlave, Trial}, " + ForSort2
		Execute t
	SetDataFolder fldrsav0
	String str0
	String IndexWaveList = WaveList("Index*Trial*", ";", "")
	Variable i, j, varIndex, varTrial
	i = 0
	do
		String SFL = StringFromList(i, IndexWaveList)
		If(Strlen(SFL)<1)
			break
		endIf
		sscanf SFL, "Index%f%s", varIndex, str0
		Variable StrStart = StrSearch(SFL, "Trial", 0)
		String SFLTruncated
		SFLTruncated = SFL[StrStart, Inf]
		sscanf SFLTruncated, "Trial%f", varTrial
		
		String StrDestWave = "Index"+Num2str(varIndex)+"_Total"
		Switch(Exists(StrDestWave))
			case 0:
				Duplicate/O $SFL, $StrDestWave
				break
			case 1:
				Wave DestWave = $StrDestWave
				Variable npnts = numpnts(DestWave)
				Variable npntssrc = numpnts($SFL)
				Redimension/N=(npnts + npntssrc) DestWave
				Wave SrcWave = $SFL
				DestWave[npnts, ] = SrcWave[p-npnts]
				break
			default:
				break
		endSwitch
		i += 1
	while(1)
	
	tSort_SortSlaveTable()
end

Function tSort_HistRasterSponta()

	DoAlert 2, "Igor is going to modify tSortListWave by evaluating marker waves. OK?"
	Switch(V_flag)
		case 1:
			tSort_EdittSortSpontaListWaves()
			break
		case 2:
			break
		case 3:
			Abort
			break
		default:
			break
	EndSwitch
	
	tSort_MakeRasterWavesSponta()

	String fldrsav0 = GetDataFolder(1)
	SetDatafolder root:Packages:tSort:
		Wave Serial1, Trial, TimeLocked, IndexSlave, BurstIndexSlave, NonBurstIndexSlave
		Wave/T wvNameSlave, tSortListWave
		String SlaveT0WL = Wavelist("*", ";", "WIN:tSortSlaveTable#T0")
		String ForSort1 = Wavelist("*", ",", "WIN:tSortSlaveTable#T0")
		String ForSort2 = ForSort1[0, (Strlen(SlaveT0WL)-1)]
		String t = "Sort/A {IndexSlave, wvNameSlave, Trial}, " + ForSort2
		Execute t
	SetDataFolder fldrsav0
	
	Variable i
	i = 0
	do
		If(Trial[i]>0)
			i += 1
			If(i > numpnts(wvNameSlave))
				break
			endIf
			continue
		endif
		
		String StrDestWave0 = "Index"+Num2str(IndexSlave[i])+"_Sponta_"+wvNameSlave[i]
		Switch(Exists(StrDestWave0))
			case 0:
				Make/n=1 $StrDestWave0
				Wave DestWave0 = $StrDestWave0
				DestWave0[0] = TimeLocked[i]
				break
			case 1:
				Wave DestWave0 = $StrDestWave0
				Variable npnts = numpnts(DestWave)
				Insertpoints npnts, 1, DestWave0
				DestWave0[npnts] = TimeLocked[i]
				break
			default:
				break
		endSwitch
		
		String StrDestWave1 = "BIndex"+Num2str(IndexSlave[i])+"_Sponta_"+wvNameSlave[i]
		Switch(Exists(StrDestWave1))
			case 0:
				Make/n=1 $StrDestWave1
				Wave DestWave1 = $StrDestWave1
				If(numtype(BurstIndexSlave[i]) != 2)
					DestWave1[0] = TimeLocked[i]
				endIf
				break
			case 1:
				Wave DestWave1 = $StrDestWave1
				npnts = numpnts(DestWave1)
				If(numtype(BurstIndexSlave[i]) != 2)
					Insertpoints npnts, 1, DestWave1
					DestWave1[npnts] = TimeLocked[i]
				endIf
				break
			default:
				break
		endSwitch
		
		String StrDestWave2 = "NBIndex"+Num2str(IndexSlave[i])+"_Sponta_"+wvNameSlave[i]
		Switch(Exists(StrDestWave2))
			case 0:
				Make/n=1 $StrDestWave2
				Wave DestWave2 = $StrDestWave2
				If(numtype(NonBurstIndexSlave[i]) != 2)
					DestWave2[0] = TimeLocked[i]
				endIf
				break
			case 1:
				Wave DestWave2 = $StrDestWave2
				npnts = numpnts(DestWave2)
				If(numtype(NonBurstIndexSlave[i]) != 2)
					Insertpoints npnts, 1, DestWave2
					DestWave2[npnts] = TimeLocked[i]
				endIf
				break
			default:
				break
		endSwitch

		i += 1
	while(i<numpnts(wvNameSlave))
	
	tSort_SortSlaveTable()
end

Function tSort_EdittSortSpontaListWaves()
	NVAR HistMarkerThreshold = root:Packages:tSort:HistMarkerThreshold
	
	Wave/T ListWave = root:Packages:tSort:tSortListWave
	Wave/T SpontaListWave = root:Packages:tSort:tSortSpontaListWave
	
	Redimension/n = 0 SpontaListWave
	
	Variable i = 0
	
	do
		Wave SpikeWave = $(ListWave[i][0])
		Wave MarkerWave = $(ListWave[i][2])
		
		FindLevels/Q/EDGE = 1 MarkerWave, HistMarkerThreshold
		Wave W_FindLevels
		If(V_flag == 2)
			Variable npnts = numpnts(SpontaListWave)+1
			Insertpoints npnts, 1, SpontaListWave
			SpontaListWave[npnts] = ListWave[i][0]
		endIf
		 
		 KillWaves W_FindLevels			
		
		i += 1
	while(i < DimSize(ListWave, 0))
end

Function tSort_MakeRasterWavesSponta()
	Wave Index = root:Packages:tSort:Index
	WaveStats/Q/M=1 Index
	Variable MaxIndex = V_max

	Wave/T SpontaListWave = root:Packages:tSort:tSortSpontaListWave
	
	Variable i, j
	
	i = 0
	do
		j = 0
		do
			String StrDestWave0 = "Index"+Num2str(j)+"_Sponta_"+SpontaListWave[i]
			String StrDestWave1 = "BIndex"+Num2str(j)+"_Sponta_"+SpontaListWave[i]
			String StrDestWave2 = "NBIndex"+Num2str(j)+"_Sponta_"+SpontaListWave[i]			
			If(Exists(StrDestWave0) == 0)
				Make/n=0 $StrDestWave0
			endIf
			If(Exists(StrDestWave1) == 0)
				Make/n=0 $StrDestWave1
			endIf
			If(Exists(StrDestWave2) == 0)
				Make/n=0 $StrDestWave2
			endIf
			Wave DestWave0 = $StrDestWave0
			Wave DestWave1 = $StrDestWave1
			Wave DestWave2 = $StrDestWave2
			Redimension/n = 0 DestWave0, DestWave1, DestWave2			
			j += 1
		while(j <= MaxIndex)
		i += 1
	while(i < numpnts(SpontaListWave))
end

Function tSort_SpontaHz_Note(ctrlName) : ButtonControl
	String ctrlName
	
	Wave Index = root:Packages:tSort:Index
	WaveStats/Q/M=1 Index
	Variable MaxIndex = V_max

	Variable i, j, TotalEvent, TotalTime, SegmentalEvent, SegmentalTime
	String notetext = ""
	
	Make/n=0 tempHz
	i = 0
	SegmentalEvent = 0
	SegmentalTime = 0
	notetext += "Total\r"
	do
		notetext += "  Index"+Num2str(i)+"\r"
		Redimension/n=0 tempHz
		String SpontaWaveList = WaveList("Index"+Num2str(i)+"_Sponta_*_spike", ";", "")
		j = 0
		TotalEvent = 0
		TotalTime = 0
		do
			String SFL = StringFromList(j, SpontaWaveList)
			If(strlen(SFL) < 1)
				break
			endIf
			String StrParentWave
			sscanf SFL, "Index"+Num2str(i)+"_Sponta_%s", StrParentWave
			Wave ParentWave = $StrParentWave
			Wave srcWRaster = $SFL
			SegmentalEvent = numpnts(srcWRaster)
			SegmentalTime = rightx(ParentWave) - leftx(parentWave)
			TotalEvent += SegmentalEvent
			TotalTime += SegmentalTime
			Variable Hz = SegmentalEvent/SegmentalTime
			notetext +=  "    " + StrParentWave + ": "+ num2str(Hz)+ "_Hz (" + num2str(SegmentalEvent) + " event/ " + num2str(SegmentalTime) + " s)\r"
			Insertpoints j, 1, tempHz
			tempHz[j] = Hz
			j += 1
		while(1)
		WaveStats/Q tempHz
		notetext += "    "+num2str(V_avg)+" ± "+num2str(V_sdev)+" Hz (Mean ± S.D.), Total event: " + num2str(TotalEvent) + ", Total dulation: " + num2str(TotalTime) + " s\r"
		i += 1
	while(i <= MaxIndex)
	KillWaves tempHz
	
	Make/n=0 tempHz
	i = 0
	SegmentalEvent = 0
	SegmentalTime = 0
	notetext += "\rBurst\r"
	do
		notetext += "  Index"+Num2str(i)+"\r"
		Redimension/n=0 tempHz
		SpontaWaveList = WaveList("BIndex"+Num2str(i)+"_Sponta_*_spike", ";", "")
		j = 0
		TotalEvent = 0
		do
			SFL = StringFromList(j, SpontaWaveList)
			If(strlen(SFL) < 1)
				break
			endIf
			sscanf SFL, "BIndex"+Num2str(i)+"_Sponta_%s", StrParentWave
			Wave ParentWave = $StrParentWave
			Wave srcWRaster = $SFL
			SegmentalEvent = numpnts(srcWRaster)
			SegmentalTime = rightx(ParentWave) - leftx(parentWave)
			TotalEvent += SegmentalEvent
			Hz = SegmentalEvent/SegmentalTime
			notetext +=  "    " + StrParentWave + ": "+ num2str(Hz)+ "_Hz (" + num2str(SegmentalEvent) + " event/ " + num2str(SegmentalTime) + " s)\r"
			Insertpoints j, 1, tempHz
			tempHz[j] = Hz
			j += 1
		while(1)
		WaveStats/Q tempHz
		notetext += "    "+num2str(V_avg)+" ± "+num2str(V_sdev)+" Hz (Mean ± S.D.), Total event: " + num2str(TotalEvent) + ", Total dulation: " + num2str(TotalTime) + " s\r"
		i += 1
	while(i <= MaxIndex)
	KillWaves tempHz
	
	Make/n=0 tempHz
	i = 0
	SegmentalEvent = 0
	SegmentalTime = 0
	notetext += "\rNonBurst\r"
	do
		notetext += "  Index"+Num2str(i)+"\r"
		Redimension/n=0 tempHz
		SpontaWaveList = WaveList("NBIndex"+Num2str(i)+"_Sponta_*_spike", ";", "")
		j = 0
		TotalEvent = 0
		do
			SFL = StringFromList(j, SpontaWaveList)
			If(strlen(SFL) < 1)
				break
			endIf
			sscanf SFL, "NBIndex"+Num2str(i)+"_Sponta_%s", StrParentWave
			Wave ParentWave = $StrParentWave
			Wave srcWRaster = $SFL
			
			SegmentalEvent = numpnts(srcWRaster)
			SegmentalTime = rightx(ParentWave) - leftx(parentWave)
			TotalEvent += SegmentalEvent
			Hz = SegmentalEvent/SegmentalTime
			notetext +=  "    " + StrParentWave + ": "+ num2str(Hz)+ "_Hz (" + num2str(SegmentalEvent) + " event/ " + num2str(SegmentalTime) + " s)\r"
			Insertpoints j, 1, tempHz
			tempHz[j] = Hz
			j += 1
		while(1)
		WaveStats/Q tempHz
		notetext += "    "+num2str(V_avg)+" ± "+num2str(V_sdev)+" Hz (Mean ± S.D.), Total event: " + num2str(TotalEvent) + ", Total dulation: " + num2str(TotalTime) + " s\r"
		i += 1
	while(i <= MaxIndex)
	KillWaves tempHz
		
	NewNotebook/F=0
	Notebook $WinName(0, 16) selection={endOfFile, endOfFile}
	Notebook $WinName(0, 16) text = notetext + "\r"
end

Function tSort_HistoPromptPanelSwitch(ctrlName) : ButtonControl
	String ctrlName
	
	ControlInfo/W=tSortMainControlPanel PopupHistAnalysisMode_tab5
	Switch(V_value)
		case 1:
			tSort_HistogramPPPSTH()
			break
		case 2:
			tSort_HistogramPPSponta()
			break
		default:
			break
	endSwitch
End

Function tSort_HistogramPPPSTH()
	NVAR HistCumTrial = root:Packages:tSort:HistCumTrial
	
	Wave Index = root:Packages:tSort:Index
	WaveStats/Q/M=1 Index
	Variable MaxIndex = V_max
	Variable i = 0
	String/G popupIndex = "All;"
	String/G popupIndexTotal = "All;"
	For(i = 0;  i <= V_max; i += 1)
		popupIndex  += num2str(i) + ";"
		popupIndexTotal += num2str(i) + ";"
	endFor

	Wave/T ListWave = root:Packages:tSort:tSortListWave
	String/G popuptWaveSort = "All;"
	For(i = 0;  i < DimSize(ListWave, 0); i += 1)
		popuptWaveSort += ListWave[i][0]+";"
	endFor

	String/G popupTrial = "All;"
	For(i = 0; i <= HistCumTrial; i += 1)
		popupTrial += num2str(i) + ";"
	endFor
	
	NewPanel/N=tSortHistogramPPPSTH/W=(100,100,400,400)
	CheckBox CheckEachTrial,pos={10,10},size={66,14},title="EachTrial",value= 0
	TitleBox title0,pos={10,25},size={45,20},title="Wave"
	TitleBox title1,pos={70,25},size={45,20},title="Index"
	TitleBox title2,pos={130,25},size={45,20},title="Pattern"
	TitleBox title3,pos={190,25},size={45,20},title="Trial"
	PopupMenu popupSettWaveSort,pos={10,50},size={42,20},mode=1,popvalue="All",value= #":popuptWaveSort"
	PopupMenu popupSetIndex,pos={70,50},size={42,20},mode=1,popvalue="All",value= #":popupIndex"
	PopupMenu popupSetPattern,pos={130,50},size={42,20},mode=1,popvalue="All",value="All;Index;Burst;NonBurst;"
	PopupMenu popupSetTrial,pos={190,50},size={42,20},popvalue="All",value= #":popupTrial"

	CheckBox CheckTotal,pos={10,90},size={44,14},title="Total",value= 0
	TitleBox title5,pos={10,105},size={35,20},title="Index"
	PopupMenu popupSetIndexTotal,pos={10,130},size={42,20},mode=1,popvalue="All",value= #":popupIndexTotal"

	Variable/G binnum = 100, binw = 0.2, binstart = -10
	SetVariable SetVarbinstart,pos={13,167},size={100,16},title="binstart",value= binstart
	SetVariable SetVarbinW,pos={13,187},size={100,16},title="binW",value= binw
	SetVariable SetVarbinnum,pos={13,207},size={100,16},title="binnum",value= binnum
	
	CheckBox CheckDisplay,pos={135,140},size={54,14},title="Display",value= 0
	CheckBox CheckLayout,pos={135,155},size={49,14},title="Layout",value= 0
	CheckBox CheckCum,pos={135,170},size={76,14},title="Cumurative",value= 0
	CheckBox CheckHz,pos={135,185},size={31,14},title="Hz",value= 0
	CheckBox CheckIndex,pos={135,200},size={31,14},title="Index label",value= 0
	CheckBox CheckSD,pos={135, 215},size={31, 14},title="SD", value= 0
	CheckBox CheckMean,pos={135, 230},size={31, 14},title="mean", value= 0	

	Button BtDoPSTH,pos={80,250},size={100,30},proc=tSort_DoPSTH,title="DoIt"
end

Function tSort_DoPSTH(ctrlName) : ButtonControl
	String ctrlName
	
	Wave Index = root:Packages:tSort:Index
	WaveStats/Q/M=1 Index
	Variable MaxIndex = V_max
	
	ControlInfo/W=tSortHistogramPPPSTH CheckLayout
	Variable ChLayout = V_value
	
	Variable i = 0

	ControlInfo/W=tSortHistogramPPPSTH CheckEachTrial
	If(V_value)
		If(ChLayout)
			NewLayout
			Printsettings/m margins={1,1,1,1}
		endIf
		ControlInfo/W=tSortHistogramPPPSTH popupSetIndex
		If(V_value == 1)
			i = 0
			do
				tSort_DoHistEachIndex(i)
				i += 1
			while(i <= MaxIndex)
		else
			tSort_DoHistEachIndex((V_value - 2))
		endIf
	endIf
	
	ControlInfo/W=tSortHistogramPPPSTH CheckTotal
	If(V_value)
		If(ChLayout)
			NewLayout
			Printsettings/m margins={1,1,1,1}
		endIf
		ControlInfo/W=tSortHistogramPPPSTH popupSetIndexTotal
		If(V_value == 1)
			i = 0
			do
				tSort_DoHistEachPatternTotal(i)
				i += 1
			while(i <= MaxIndex)
		else
			tSort_DoHistEachPatternTotal((V_value - 2))
		endIf
	endIf
	
	tSort_KilltSortHistogramPPPSTH()
end

Function tSort_DoHistEachIndex(index)
	Variable index
	
	Wave/T ListWave = root:Packages:tSort:tSortListWave
	
	ControlInfo/W=tSortHistogramPPPSTH popupSettWaveSort
	If(V_value == 1)
		Variable i = 0
		do
			String StrSpikeWave = ListWave[i][0]
				tSort_DoHistEachTrial(index, StrSpikeWave)
			i += 1
		while(i < DimSize(ListWave, 0))
	else
		tSort_DoHistEachTrial(index, S_value)
	endIf
end

Function tSort_DoHistEachTrial(index, StrSpikeWave)
	Variable index
	String StrSpikeWave
	
	NVAR HistCumTrial = root:Packages:tSort:HistCumTrial
	
	ControlInfo/W=tSortHistogramPPPSTH popupSetTrial
	If(V_value == 1)
		Variable i = 0
		do
			tSort_DoHistEachPattern(index, StrSpikeWave, i)
			i += 1
		while(i <= HistCumTrial)
	else
		tSort_DoHistEachPattern(index, StrSpikeWave, (V_value - 2))
	endIf
end

Function tSort_DoHistEachPattern(index, StrSpikeWave, trial)
	Variable index, trial
	String StrSpikeWave
	
	ControlInfo/W=tSortMainControlPanel PopupHistAnalysisMode_tab5
	Switch(V_value)
		case 1:
			ControlInfo/W=tSortHistogramPPPSTH popupSetPattern
			break
		case 2:
			ControlInfo/W=tSortHistogramPPSponta popupSetPattern
			break
		default:
			break
	endSwitch
	

	If(V_value == 1)
		String StrPrefix = "Index"
		String StrSrcWave = StrPrefix+Num2str(index)+"_"+StrSpikeWave+"_Trial"+Num2str(trial)
		tSort_DoHistAnalysisPSTH(StrSrcWave, StrPrefix, 0)
		
		StrPrefix = "BIndex"	
		StrSrcWave = StrPrefix+Num2str(index)+"_"+StrSpikeWave+"_Trial"+Num2str(trial)
		tSort_DoHistAnalysisPSTH(StrSrcWave, StrPrefix, 0)

		StrPrefix = "NBIndex"			
		StrSrcWave = StrPrefix+Num2str(index)+"_"+StrSpikeWave+"_Trial"+Num2str(trial)
		tSort_DoHistAnalysisPSTH(StrSrcWave, StrPrefix, 0)
	else
		Switch (V_value)
			case 2:
				StrPrefix= "Index"
				break
			case 3:
				StrPrefix = "BIndex"	
				break
			case 4:
				StrPrefix = "NBIndex"			
				break
			default:
				break
		endSwitch
		StrSrcWave = StrPrefix+Num2str(index)+"_"+StrSpikeWave+"_Trial"+Num2str(trial)
		tSort_DoHistAnalysisPSTH(StrSrcWave, StrPrefix, 0)
	endIf
end

Function tSort_DoHistEachPatternTotal(index)
	Variable index

	ControlInfo/W=tSortHistogramPPSponta popupSetPattern
	If(V_value == 1)
		String StrPrefix = "Index"
		String StrSrcWave = StrPrefix+Num2str(index)+"_Total"
		tSort_DoHistAnalysisPSTH(StrSrcWave, StrPrefix, 1)
		
		StrPrefix = "BIndex"
		StrSrcWave = StrPrefix+Num2str(index)+"_Total"
		tSort_DoHistAnalysisPSTH(StrSrcWave, StrPrefix, 1)
		
		StrPrefix = "NBIndex"
		StrSrcWave = StrPrefix+Num2str(index)+"_Total"
		tSort_DoHistAnalysisPSTH(StrSrcWave, StrPrefix, 1)
	else
		Switch (V_value)
			case 2:
				StrPrefix = "Index"
				break
			case 3:
				StrPrefix = "BIndex"
				break
			case 4:
				StrPrefix = "NBIndex"				
				break
			default:
				break
		endSwitch
		StrSrcWave = StrPrefix+Num2str(index)+"_Total"
		tSort_DoHistAnalysisPSTH(StrSrcWave, StrPrefix, 1)
	endIf
end

Function tSort_DoHistAnalysisPSTH(StrSrcWave, StrPrefix total)
	String StrSrcWave, StrPrefix
	Variable total

	Wave srcWave = $StrSrcWave
	
	NVAR HistTimeWindow = root:Packages:tSort:HistTimeWindow
	NVAR binnum = :binnum
	NVAR binw = :binw
	NVAR binstart = :binstart
	NVAR HistStdDev = root:Packages:tSort:HistStdDev
	NVAR HistMean = root:Packages:tSort:HistMean
	
	ControlInfo/W=tSortHistogramPPPSTH CheckCum
	If(V_value)
		String StrDestWave = StrSrcWave+"_Cum"
		If(Exists(StrSrcWave))
			Make/C/N=(binnum)/O $StrDestWave
			Histogram/CUM/B={binstart,binw,binnum} $StrSrcWave, $StrDestWave
		endIf
	else
		StrDestWave = StrSrcWave+"_Hist"
		If(Exists(StrSrcWave))
			Make/N=(binnum)/O $StrDestWave
			Histogram/B={binstart,binw,binnum} srcWave, $StrDestWave
		endIf
	endIf
	
	If(Exists(StrDestWave))
		Wave DestWave = $StrDestWave
		
		If(total)
			NVAR HistCumTrial = root:Packages:tSort:HistCumTrial
			DestWave /= HistCumTrial
		endIf
	
		ControlInfo/W=tSortHistogramPPPSTH CheckHz
		If(V_value)
			DestWave /= binw
		endIf
		
		ControlInfo/W=tSortHistogramPPPSTH CheckSD
		If(V_value)
			WaveStats/Q/R=(-HistTimeWindow/2, 0 - deltax(DestWave)) DestWave
			Duplicate/O $StrDestWave, $(StrDestWave + "_SD")
			Wave SD_Wave = $(StrDestWave + "_SD")
			SD_Wave = V_sdev * HistStdDev
		endIf
		
		ControlInfo/W=tSortHistogramPPPSTH CheckMean
		If(V_value)
			WaveStats/Q/R=(-HistTimeWindow/2, 0 - deltax(DestWave)) DestWave
			Duplicate/O $StrDestWave, $(StrDestWave + "_MeanBaseline")
			Wave MeanBaseline_Wave = $(StrDestWave + "_MeanBaseline")
			MeanBaseline_Wave = V_avg * HistMean
		endIf
			
		ControlInfo/W=tSortHistogramPPPSTH CheckDisplay
		If(V_value)
			Display DestWave
			ModifyGraph width=141.732,height=141.732
			Variable IndexValue
			String str
			sscanf StrDestWave, StrPrefix+"%f_%s", IndexValue, str
			ModifyGraph mode=5,hbFill=2,rgb=(tSort_Rainbow256(IndexValue, 0), tSort_Rainbow256(IndexValue, 1), tSort_Rainbow256(IndexValue, 2))
			Label bottom "s"
			
			ControlInfo/W=tSortHistogramPPPSTH CheckIndex
			If(V_value)
				If(total)
					TextBox/C/N=text0/F=0/A=MC/X=-30/Y=50 StrPrefix+ Num2str(IndexValue) + " Average"
				else
					TextBox/C/N=text0/F=0/A=MC/X=-30/Y=50 StrPrefix+ Num2str(IndexValue)
				endIf
			endIf
			
			ControlInfo/W=tSortHistogramPPPSTH CheckHz
			If(V_value)
				Label left "Hz"
			endIf
			
			ControlInfo/W=tSortHistogramPPPSTH CheckLayout
			If(V_value)
				AppendLayoutObject/W=$WinName(0, 4) graph $WinName(0, 1)
				DoWindow/HIDE=1 $WinName(0, 1)
			endIf
			
			ControlInfo/W=tSortHistogramPPPSTH CheckSD
			If(V_value)
				AppendToGraph SD_Wave
				ModifyGraph lstyle($(StrDestWave + "_SD"))=3, rgb=(tSort_Rainbow256(IndexValue, 0), tSort_Rainbow256(IndexValue, 1), tSort_Rainbow256(IndexValue, 2))
			endIf
			
			ControlInfo/W=tSortHistogramPPPSTH CheckMean
			If(V_value)
				AppendToGraph MeanBaseline_Wave
				ModifyGraph lstyle($(StrDestWave + "_MeanBaseline"))=1, rgb=(tSort_Rainbow256(IndexValue, 0), tSort_Rainbow256(IndexValue, 1), tSort_Rainbow256(IndexValue, 2))
			endIf
		endIf
	endIf
end

Function tSort_KilltSortHistogramPPPSTH()
	KillWindow tSortHistogramPPPSTH
	KillStrings/Z popupIndex, popuptWaveSort, popupTrial
	KillVariables/Z binnum, binW, binstart
end

Function tSort_HistogramPPSponta()
	Wave Index = root:Packages:tSort:Index
	WaveStats/Q/M=1 Index
	Variable MaxIndex = V_max
	
	Variable i = 0
	String/G popupIndex = "All;"
	For(i = 0;  i <= V_max; i += 1)
		popupIndex  += num2str(i) + ";"
	endFor
	
	Wave/T ListWave = root:Packages:tSort:tSortListWave
	String/G popuptWaveSort = "All;"
	For(i = 0;  i < DimSize(ListWave, 0); i += 1)
		popuptWaveSort += ListWave[i][0]+";"
	endFor
	
	NewPanel/N=tSortHistogramPPSponta/W=(100,100,400,400)
	TitleBox title0,pos={10,7},size={35,20},title="Wave"
	TitleBox title1,pos={70,7},size={35,20},title="Index"
	TitleBox title2,pos={130,7},size={45,20},title="Pattern"
	PopupMenu popupSettWaveSort,pos={10,30},size={42,20},mode=1,popvalue="All",value= #":popuptWaveSort"
	PopupMenu popupSetIndex,pos={70,30},size={42,20},mode=1,popvalue="All",value= #":popupIndex"
	PopupMenu popupSetPattern,pos={130,30},size={42,20},mode=1,popvalue="All",value="All;Index;Burst;NonBurst;"

	Variable/G binnum = 120, binw = 0.5, binstart = 0
	SetVariable SetVarbinstart,pos={13,167},size={100,16},title="binstart",value= binstart
	SetVariable SetVarbinW,pos={13,187},size={100,16},title="binW",value= binw
	SetVariable SetVarbinnum,pos={13,207},size={100,16},title="binnum",value= binnum
	
	CheckBox CheckDisplay,pos={135,170},size={54,14},title="display",value= 0
	CheckBox CheckLayout,pos={135,185},size={49,14},title="layout",value= 0
	CheckBox CheckCum,pos={135,200},size={76,14},title="Cumurative",value= 0
	CheckBox CheckHz,pos={135,215},size={31,14},title="Hz",value= 0
	CheckBox CheckIndex,pos={135,230},size={31,14},title="Index label",value= 0

	Button BtDoSponta,pos={80,250},size={100,30},proc=tSort_DoSponta,title="DoIt"
end

Function tSort_DoSponta(ctrlName) : ButtonControl
	String ctrlName
	
	Wave Index = root:Packages:tSort:Index
	WaveStats/Q/M=1 Index
	Variable MaxIndex = V_max
		
	Variable i, j

	ControlInfo/W=tSortHistogramPPSponta CheckLayout
	If(V_value)
		NewLayout
		Printsettings/m margins={1,1,1,1}
	endIf

	ControlInfo/W=tSortHistogramPPSponta popupSetIndex
	If(V_value == 1)
		i = 0
		do
			ControlInfo/W=tSortHistogramPPSponta popupSetPattern
			If(V_value == 1)
				For(j = 1; j < 4; j += 1)
					tSort_HistSpontaIndex(i, j)
					tSort_HistSpontaAvg(i, j)
				endFor
			else
				tSort_HistSpontaIndex(i, V_value)
				tSort_HistSpontaAvg(i, V_value)
			endIf
			i += 1
		while(i <= MaxIndex)
	else
		Variable varIndex = (V_value - 2)
		ControlInfo/W=tSortHistogramPPSponta popupSetPattern
		If(V_value == 1)
			For(j = 1; j < 4; j += 1)
				tSort_HistSpontaIndex(varIndex, j)
			endFor
		else
			tSort_HistSpontaIndex(varIndex, V_value)
		endIf
	endIf
		
	tSort_KilltSortHistoPPSponta()
end

Function tSort_HistSpontaAvg(Index, Pattern)
	Variable Index, Pattern
	
	Switch(Pattern)
		case 1:
			String StrPrefix = "Index"
			break
		case 2:
			StrPrefix = "BIndex"
			break
		case 3:
			StrPrefix = "NBIndex"
			break
		default:
			break
	endSwitch
	
	ControlInfo/W=tSortHistogramPPSponta CheckCum
	If(V_value)
		String SrcWaveList = WaveList(StrPrefix+Num2str(Index)+"_Sponta_*_Cum", ";", "")
	else
		SrcWaveList = WaveList(StrPrefix+Num2str(Index)+"_Sponta_*_Hist", ";", "")
	endIf

	Variable i = 0
	
	do
		String SFL = StringFromList(i, SrcWaveList)
		If(strlen(SFL)<1)
			break
		endIf
		If(i == 0)
			Duplicate/O $SFL, $(StrPrefix+Num2str(Index)+"_Avg")
			Wave avg = $(StrPrefix+Num2str(Index)+"_Avg")		
			i += 1
		else	
			Wave srcW = $SFL
			avg += srcW
			i += 1		
		endIf
	while(1)

	avg /= i
	
	ControlInfo/W=tSortHistogramPPSponta CheckDisplay
	If(V_value)
		Display avg
		ModifyGraph width=141.732,height=141.732
		ModifyGraph mode=5,hbFill=2,rgb=(tSort_Rainbow256(Index, 0), tSort_Rainbow256(Index, 1), tSort_Rainbow256(Index, 2))
		Label bottom "s"
		
		ControlInfo/W=tSortHistogramPPSponta CheckIndex
		If(V_value)
			TextBox/C/N=text0/F=0/A=MC/X=-30/Y=50 StrPrefix+ Num2str(Index)+" Avg"
		endIf
		
		ControlInfo/W=tSortHistogramPPSponta CheckHz
		If(V_value)
			Label left "Hz"
		endIf
		
		ControlInfo/W=tSortHistogramPPSponta CheckLayout
		If(V_value)
			AppendLayoutObject/W=$WinName(0, 4) graph $WinName(0, 1)
			DoWindow/HIDE=1 $WinName(0, 1)
		endIf
	endIf
end

Function tSort_HistSpontaIndex(Index, Pattern)
	Variable Index, Pattern
	
	Switch(Pattern)
		case 1:
			String StrPrefix = "Index"
			break
		case 2:
			StrPrefix = "BIndex"
			break
		case 3:
			StrPrefix = "NBIndex"
			break
		default:
			break
	endSwitch

	Wave/T ListWave = root:Packages:tSort:tSortListWave
		
	ControlInfo/W=tSortHistogramPPSponta popupSettWaveSort
	If(V_value == 1)
		Variable i = 0
		do
			String tWaveSort = ListWave[i][0]
			String StrSrcWave = StrPrefix+Num2str(index)+"_Sponta_"+tWaveSort
			tSort_DoHistAnalysisSponta(StrSrcWave, StrPrefix)
			i += 1
		while(i < DimSize(ListWave, 0))
	else
		StrSrcWave = StrPrefix+Num2str(index)+"_Sponta_"+S_value
		tSort_DoHistAnalysisSponta(StrSrcWave, StrPrefix)
	endIf
end

Function tSort_DoHistAnalysisSponta(StrSrcWave, StrPrefix)
	String StrSrcWave, StrPrefix

	Wave srcWave = $StrSrcWave
	
	NVAR binnum = :binnum
	NVAR binw = :binw
	NVAR binstart = :binstart
	
	ControlInfo/W=tSortHistogramPPSponta CheckCum
	If(V_value)
		String StrDestWave = StrSrcWave+"_Cum"
		If(Exists(StrSrcWave))
			Make/C/N=(binnum)/O $StrDestWave
			Histogram/B={binstart,binw,binnum} $StrSrcWave, $StrDestWave
		endIf
	else
		StrDestWave = StrSrcWave+"_Hist"
		If(Exists(StrSrcWave))
			Make/N=(binnum)/O $StrDestWave
			Histogram/B={binstart,binw,binnum} srcWave, $StrDestWave
		endIf
	endIf
	
	If(Exists(StrDestWave))
		Wave DestWave = $StrDestWave
	
		ControlInfo/W=tSortHistogramPPSponta CheckHz
		If(V_value)
			DestWave /= binw
		endIf
			
		ControlInfo/W=tSortHistogramPPSponta CheckDisplay
		If(V_value)
			Display DestWave
			ModifyGraph width=141.732,height=141.732			
			Variable IndexValue
			String str
			sscanf StrDestWave, StrPrefix+"%f_%s", IndexValue, str
			ModifyGraph mode=5,hbFill=2,rgb=(tSort_Rainbow256(IndexValue, 0), tSort_Rainbow256(IndexValue, 1), tSort_Rainbow256(IndexValue, 2))
			Label bottom "s"
			
			ControlInfo/W=tSortHistogramPPSponta CheckIndex
			If(V_value)
				TextBox/C/N=text0/F=0/A=MC StrPrefix + " " + Num2str(IndexValue)
			endIf
			
			ControlInfo/W=tSortHistogramPPSponta CheckHz
			If(V_value)
				Label left "Hz"
			endIf
			
			ControlInfo/W=tSortHistogramPPSponta CheckLayout
			If(V_value)
				AppendLayoutObject/W=$WinName(0, 4) graph $WinName(0, 1)
				DoWindow/HIDE=1 $WinName(0, 1)
			endIf
		endIf
	endIf
end

Function tSort_KilltSortHistoPPSponta()
	KillWindow tSortHistogramPPSponta
	KillStrings/Z popupIndex, popuptWaveSort
	KillVariables/Z binnum, binW, binstart
end

Function tSort_KillGraphs(ctrlName) : ButtonControl
	String ctrlName

	String list = winlist("Graph*", ";", "")
	Variable i = 0
	do
		String sfl = StringFromList(i, list)
		If(strlen(sfl)<1)
			break
		endif
		String cmd = "DoWindow/K " + sfl
		Execute cmd
		i += 1
	while(1)
End

Function tSort_tWaveSortGraph(ctrlName) : ButtonControl
	String ctrlName
	
	SVAR tWaveSort = root:Packages:tSort:tWaveSort
	tSort_TargetWaveGraph(tWaveSort)
	tSort_tWaveSortGraphTransform(tWaveSort)
end

Function tSort_EachTrialGraph(ctrlName) : ButtonControl
	String ctrlName
	
	NVAR HistTrial = root:Packages:tSort:HistTrial
	NVAR HistTimeWindow = root:Packages:tSort:HistTimeWindow
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		Wave/T wvNameSlave
		Wave Trial, Trigger
		
		Variable i = 0
		
		do
			If(Trial[i] == HistTrial)
				String StrSrcWave = wvNameSlave[i]
				Variable TimeStart = Trigger[i]
				break
			else
				If(i > 10000)
					SetDataFolder fldrSav0
					Abort
				endIf
			endIf
			i += 1
		while(1)
	SetDataFolder fldrSav0
	
	Wave srcWave = $StrSrcWave
	
	tSort_TargetWaveGraph(StrSrcWave)
	tSort_tWaveSortGraphTransform(StrSrcWave)
	
	SetAxis bottom (TimeStart - HistTimeWindow/2),(TimeStart + HistTimeWindow/2)
End

Function tSort_TargetWaveGraph(StrTargetWave)
	String StrTargetWave
	
	NVAR bitDispMode = root:Packages:tSort:bitDispMode
	Wave srcWave = $strTargetWave
	
	tSort_MakeLabelWave()
	
	Wave/T ListWave = root:Packages:tSort:tSortListWave
	ControlInfo/W=tSortMainControlPanel SortWaveList_tab0
	If(V_value < 0)
		V_value = 0
	endIf

	String StrSpikeWave = ListWave[V_value][0]
	String StrLFPWave = ListWave[V_value][1]
	String StrECoGWave = ListWave[V_value][2]
	String StrEMGWave = ListWave[V_value][3]
	String StrMarkerWave = ListWave[V_value][4]

	Wave SpikeWave = $StrSpikeWave
	Wave LFPWave = $StrLFPWave
	Wave ECoGWave = $StrECoGWave
	Wave EMGWave = $StrEMGWave
	Wave MarkerWave = $StrMarkerWave
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		Wave Index,MainGraphIndex,MainGraphBIndex,MainGraphNBIndex,MainGraphXLock
		Variable IndexMax = Wavemax(Index)
	
		Display
	
		If(bitDispMode & 2^0)	
			AppendToGraph SpikeWave
		endIf

		If(bitDispMode & 2^1)
			AppendToGraph/L=LFPAxis LFPWave
		endIf

		If(bitDispMode & 2^2)
			AppendToGraph/L=ECoGAxis ECoGWave
		endIf

		If(bitDispMode & 2^3)
			AppendToGraph/L=EMGAxis EMGWave
		endIf

		If(bitDispMode & 2^4)
			AppendToGraph/L=MarkerAxis MarkerWave
		endIf
	
		If(bitDispMode & 2^5)
			AppendToGraph/L=IndexAxis MainGraphIndex vs MainGraphXLock
		
			If(numtype(IndexMax) ==2 || IndexMax == 0)
				ModifyGraph zColor(MainGraphIndex)=0
			else
				SetAxis IndexAxis -inf, +inf
				ModifyGraph  zColor(MainGraphIndex)={MainGraphIndex,*,IndexMax,Rainbow256,0}
			endIf
		endIf
		
		If(bitDispMode & 2^6)
			AppendToGraph/L=BIndexAxis MainGraphBIndex vs MainGraphXLock
			If(numtype(IndexMax) ==2 || IndexMax == 0)
				ModifyGraph zColor(MainGraphBIndex)=0
			else
				SetAxis BIndexAxis -inf, +inf
				ModifyGraph  zColor(MainGraphBIndex)={MainGraphBIndex,*,IndexMax,Rainbow256,0}
			endIf
		endIf
		
		If(bitDispMode & 2^7)
			AppendToGraph/L=NBIndexAxis MainGraphNBIndex vs MainGraphXLock
			If(numtype(IndexMax) ==2 || IndexMax == 0)
				ModifyGraph zColor(MainGraphNBIndex)=0
			else
				SetAxis NBIndexAxis -inf, +inf
				ModifyGraph  zColor(MainGraphNBIndex)={MainGraphNBIndex,*,IndexMax,Rainbow256,0}
			endIf
		endIf
	
		GetAxis/W=tSortMainGraph bottom
		SetAxis bottom V_min, V_max
	
	SetDataFolder fldrSav0
End

Function tSort_tWaveSortGraphTransform(StrTargetWave)
	String StrTargetWave

	SVAR StrWeightList = root:Packages:tSort:StrWeightList
	
	NVAR bitDispMode = root:Packages:tSort:bitDispMode
	NVAR SecureVal = root:Packages:tSort:MainGraphSecureVal
	NVAR SpacerVal = root:Packages:tSort:MainGraphSpacerVal

	Wave/T ListWave = root:Packages:tSort:tSortListWave
	
	Variable i = 0
	do
		If(StringMatch(StrTargetWave, ListWave[i][0]))
			break
		endIf
		i += 1
		If(i > DimSize(ListWave, 0))
			Print "No Match!! tWaveSort!!"
			Abort
		endIf
	while(1)
	
	ControlInfo/W=tSortMainControlPanel SortWaveList_tab0
	If(V_value < 0)
		V_value = 0
	endIf
	
	String StrSpikeWave = ListWave[V_value][0]
	String StrLFPWave = ListWave[V_value][1]
	String StrECoGWave = ListWave[V_value][2]
	String StrEMGWave = ListWave[V_value][3]
	String StrMarkerWave = ListWave[V_value][4]

	Wave SpikeWave = $StrSpikeWave
	Wave LFPWave = $StrLFPWave
	Wave ECoGWave = $StrECoGWave
	Wave EMGWave = $StrEMGWave
	Wave MarkerWave = $StrMarkerWave
	Wave MainGraphIndex = root:Packages:tSort:MainGraphIndex
	Wave MainGraphBIndex = root:Packages:tSort:MainGraphBIndex
	Wave MainGraphNBIndex = root:Packages:tSort:MainGraphNBIndex
	Wave MainGraphXLock = root:Packages:tSort:MainGraphXLock

	Variable TraceUnits = 0
	
	for(i = 0; i < 7; i +=1)
		If(bitDispMode & 2^i)
			Variable WeightValue = str2num(StringFromList(i, StrWeightList))
			TraceUnits += WeightValue
		endIf
	endfor
	
	TraceUnits *= SecureVal
	
	Variable axisBottomRatio = 0, axisTopRatio = 0

	If(bitDispMode & 2^0)
		axisTopRatio = axisBottomRatio + str2num(StringFromList(0, StrWeightList))/TraceUnits
		ModifyGraph axisEnab(left) = {axisBottomRatio, axisTopRatio}
		ModifyGraph lblPos(left)=75,lblRot(left)=-90
		Label left "Spike"
		axisBottomRatio = axisTopRatio + SpacerVal
	endIf
	
	If(bitDispMode & 2^5)
		axisTopRatio =axisBottomRatio + str2num(StringFromList(5, StrWeightList))/TraceUnits
		ModifyGraph axisEnab(IndexAxis) = {axisBottomRatio, axisTopRatio}, freePos(IndexAxis)=0
		ModifyGraph noLabel(IndexAxis)=1,axThick(IndexAxis)=0,lblPos(IndexAxis)=75
		ModifyGraph lblRot(IndexAxis)=-90
		ModifyGraph mode(MainGraphIndex)=3, marker(MainGraphIndex)=10
//		Wavestats/Q MainGraphIndex
//		ModifyGraph zColor(MainGraphIndex)={MainGraphIndex,*,V_max,Rainbow256,0}
		Label IndexAxis "Detection"
		axisBottomRatio = axisTopRatio + SpacerVal
	endIf
	
	If(bitDispMode & 2^6)
		axisTopRatio = axisBottomRatio + str2num(StringFromList(6, StrWeightList))/TraceUnits
		ModifyGraph axisEnab(BIndexAxis) = {axisBottomRatio+0.02, axisTopRatio-0.02}, freePos(BIndexAxis)=0
		ModifyGraph noLabel(BIndexAxis)=1,axThick(BIndexAxis)=0,lblPos(BIndexAxis)=75
		ModifyGraph lblRot(BIndexAxis)=-90
		ModifyGraph mode(MainGraphBIndex)=3, marker(MainGraphBIndex)=10
		Label BIndexAxis "Burst"
		axisBottomRatio = axisTopRatio + SpacerVal
	endIf
	
	If(bitDispMode & 2^7)
		axisTopRatio = axisBottomRatio + str2num(StringFromList(7, StrWeightList))/TraceUnits
		ModifyGraph axisEnab(NBIndexAxis) = {axisBottomRatio, axisTopRatio}, freePos(NBIndexAxis)=0
		ModifyGraph noLabel(NBIndexAxis)=1,axThick(NBIndexAxis)=0,lblPos(NBIndexAxis)=75
		ModifyGraph lblRot(NBIndexAxis)=-90
		ModifyGraph mode(MainGraphNBIndex)=3, marker(MainGraphNBIndex)=10
		Label NBIndexAxis "NonB"
		axisBottomRatio = axisTopRatio + SpacerVal
	endIf
	
	If(bitDispMode & 2^1)
		axisTopRatio =axisBottomRatio + str2num(StringFromList(1, StrWeightList))/TraceUnits
		ModifyGraph axisEnab(LFPAxis) = {axisBottomRatio, axisTopRatio}, freePos(LFPAxis)=0
		ModifyGraph lblPos(LFPAxis)=75,lblRot(LFPAxis)=-90
		Label LFPAxis "LFP"
		axisBottomRatio = axisTopRatio + SpacerVal
	endIf
	
	If(bitDispMode & 2^2)
		axisTopRatio = axisBottomRatio + str2num(StringFromList(2, StrWeightList))/TraceUnits
		ModifyGraph axisEnab(ECoGAxis) = {axisBottomRatio, axisTopRatio}, freePos(ECoGAxis)=0
		ModifyGraph lblPos(ECoGAxis)=75,lblRot(ECoGAxis)=-90
		Label ECoGAxis "ECoG"
		axisBottomRatio = axisTopRatio + SpacerVal
	endIf
	
	If(bitDispMode & 2^3)
		axisTopRatio = axisBottomRatio + str2num(StringFromList(3, StrWeightList))/TraceUnits
		ModifyGraph axisEnab(EMGAxis) = {axisBottomRatio, axisTopRatio}, freePos(EMGAxis)=0
		ModifyGraph lblPos(EMGAxis)=75,lblRot(EMGAxis)=-90
		Label EMGAxis "EMG"
		axisBottomRatio = axisTopRatio + SpacerVal
	endIf
	
	If(bitDispMode & 2^4)
		axisTopRatio = axisBottomRatio + str2num(StringFromList(4, StrWeightList))/TraceUnits
		ModifyGraph axisEnab(MarkerAxis) = {axisBottomRatio, axisTopRatio}, freePos(MarkerAxis)=0
		ModifyGraph lblPos(MarkerAxis)=75,lblRot(MarkerAxis)=-90
		Label MarkerAxis "Marker"
	endIf
	
	
end

Function tSort_AllTrialGraph(ctrlName) : ButtonControl
	String ctrlName
	
	tSort_MakeTriaIndexTimeLocked()
	tSort_MakeTrialSpikeMarker()

	NVAR HistCumTrial = root:Packages:tSort:HistCumTrial
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		Wave Index
		Variable IndexMax=Wavemax(Index)
	SetDataFolder fldrSav0
	
	Display
	
	Variable i = 0
	i = 0
	do	
		Wave wSpike = $("Trial"+Num2str(i)+"_Spike")
		Wave wMarker = $("Trial"+Num2str(i)+"_Marker")
		Wave wIndex = $("Trial"+Num2str(i)+"_Index")
		Wave wTimeLocked = $("Trial"+Num2str(i)+"_TimeLocked")
		
		AppendToGraph wSpike
		If(i == 0)
			AppendToGraph/L=$("MarkerAxis"+Num2str(i)) wMarker
		endIf
		AppendToGraph/L=$("IndexAxis"+Num2str(i)) wIndex vs wTimeLocked
		
		
		ModifyGraph noLabel($("IndexAxis"+Num2str(i)))=2,axThick($("IndexAxis"+Num2str(i)))=0
		ModifyGraph axisEnab($("IndexAxis"+Num2str(i)))={1 - 0.5/HistCumTrial -0.5*i/HistCumTrial,1 - 0.5*i/HistCumTrial},freePos($("IndexAxis"+Num2str(i)))=0
		ModifyGraph mode($("Trial"+Num2str(i)+"_Index"))=3,marker($("Trial"+Num2str(i)+"_Index"))=10
		If(HistCumTrial > 10)
			ModifyGraph msize($("Trial"+Num2str(i)+"_Index"))=30/HistCumTrial
		endIf
		
		SetAxis $("IndexAxis"+Num2str(i)) -inf, +inf
		If(IndexMax)
			ModifyGraph zColor($("Trial"+Num2str(i)+"_Index"))={$("Trial"+Num2str(i)+"_Index"),*,IndexMax,Rainbow256,0}
		endIf

		If(i == 0)
			ModifyGraph noLabel($("MarkerAxis"+Num2str(i)))=2,axThick($("MarkerAxis"+Num2str(i)))=0
			ModifyGraph axisEnab($("MarkerAxis"+Num2str(i)))={0,0.09},freePos($("MarkerAxis"+Num2str(i)))=0
		endIf		
		
		i += 1
	while(i < HistCumTrial)
	
	ModifyGraph axisEnab(left) = {0.1, 0.48}
End

Function tSort_MakeTriaIndexTimeLocked()

	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		Wave Trial, IndexSlave, TimeLocked
	SetDataFolder fldrSav0
	
	Variable i = 0 
	Variable flag = 0
	
	do		// raster
		String StrTrialIndex = "Trial"+Num2str(Trial[i])+"_Index"
		String StrTrialTimeLocked = "Trial"+Num2str(Trial[i])+"_TimeLocked"
		Switch(Exists(StrTrialIndex))
			case 0:
				Make/n = 1 $StrTrialIndex, $StrTrialTimeLocked
				Wave wTrialIndex = $StrTrialIndex
				Wave wTrialTimeLocked = $StrTrialTimeLocked
				wTrialIndex[0] = IndexSlave[i]
				wTrialTimeLocked[0] = TimeLocked[i]
				break
			case 1:
				Variable npnts = numpnts(wTrialIndex)
				If(i == 0)
					flag = 1
					break
				endIf
				If(flag == 1)
					break
				endIf
				Insertpoints npnts, 1, wTrialIndex, wTrialTimeLocked
				wTrialIndex[npnts] = IndexSlave[i]
				wTrialTimeLocked[npnts] = TimeLocked[i]
				break
			default:
				break
		endSwitch
		i += 1
	while(i < numpnts(Trial))
End

Function tSort_MakeTrialSpikeMarker()
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		Wave/T wvNameSlave
		Wave Trial, IndexSlave, TimeLocked, Trigger
	SetDataFolder fldrSav0
	
	NVAR HistCumTrial = root:Packages:tSort:HistCumTrial
	NVAR HistTimeWindow = root:Packages:tSort:HistTimeWindow
		
	Variable i = 0
	
	String StrsrcW = wvNameSlave[i]

	Wave srcW = $StrsrcW
	Duplicate/O srcW, wtemp
	Wave wtemp
	Redimension/n=(HistTimeWindow/deltax(srcW)) wtemp
	SetScale/P x -(HistTimeWindow/2),deltax(srcW),"s", wtemp
	
	Wave/T ListWave = root:Packages:tSort:tSortListWave
	i = 0
	do
		If(StringMatch(StrsrcW, ListWave[i][0]))
			String StrsrcWMarker = ListWave[i][2]
			Wave srcWMarker = $STrsrcWMarker
			break
		endIf
		i += 1
	while(i < DimSize(ListWave, 0))
	Duplicate/O srcWMarker, wtempMarker
	Wave wtempMarker
	Redimension/n=(HistTimeWindow/deltax(srcWMarker)) wtempMarker
	SetScale/P x -(HistTimeWindow/2),deltax(srcWMarker),"s", wtempMarker
	
	i = 0
	do
		Variable j = 0
		do
			If(i == Trial[j])
				StrsrcW = wvNameSlave[j]
				Wave srcW = $StrsrcW
				Variable  TriggerTime = Trigger[j]
				Variable k = 0
				do
					If(StringMatch(StrsrcW, ListWave[k][0]))
						StrsrcWMarker = ListWave[k][2]
						Wave srcWMarker = $STrsrcWMarker
						break
					endIf
					k += 1
				while(k < DimSize(ListWave, 0))
				break
			endIf
			j += 1
		while(j < numpnts(wvNameSlave))
		
		Duplicate/O wtemp, $("Trial"+Num2str(i)+"_Spike")
		Wave destW = $("Trial"+Num2str(i)+"_Spike")
		destW[p, ] = srcW[p + x2pnt(srcW, TriggerTime) - (HistTimeWindow/2)/deltax(srcW)]
		
		If(i == 0)
			Duplicate/O wtempMarker, $("Trial"+Num2str(i)+"_Marker")
			Wave destWMarker = $("Trial"+Num2str(i)+"_Marker")
			destWMarker[p, ] = srcWMarker[p + x2pnt(srcWMarker, TriggerTime) - (HistTimeWindow/2)/deltax(srcWMarker)]
		endIf
		
		i += 1
	while(i < HistCumTrial)
	
	KillWaves wtemp, wtempMarker
End

Function tSort_PlainEventGraph(ctrlName) : ButtonControl
	String ctrlName

	Display
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:

		Wave Index
		Variable i = 0
		Variable npnts = numpnts(Index)
	 
		 do
		 	String StrEventWave = "Event_" + Num2str(i+1)
		 	Wave EventWave = $StrEventWave
			AppendToGraph/C=(tSort_Rainbow256(Index[i], 0), tSort_Rainbow256(Index[i], 1), tSort_Rainbow256(Index[i], 2)) $StrEventWave
		 	i += 1
		 while(i < npnts-1)
		 		
	SetDataFolder fldrSav0
End


Function tSort_NewPCGizmo(ctrlName) : ButtonControl
	String ctrlName
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		ColorTab2Wave Rainbow256
		Wave M_colors, Index, PC1, PC2, PC3
		
		WMXYZToXYZTriplet(PC1,PC2,PC3, "xyzPC")
				
		Duplicate/O Index Index_Sorted
		WMXYZTripletToXYZWaves(xyzPC,"PC1_Sorted", "PC2_Sorted", "PC3_Sorted")
		Sort Index_Sorted, PC1_Sorted, PC2_Sorted, PC3_Sorted, Index_Sorted
		
		Variable boundary0, boundary1, j=Wavemax(Index), numClasses=Wavemax(Index)
		Variable cIndex=round(DimSize(M_colors,0)/numClasses)
		
		Execute "NewGizmo"
		Execute "ModifyGizmo euler={25,-25,0}"

		do
	
			boundary0=BinarySearch(Index_Sorted,j)
			boundary1=BinarySearch(Index_Sorted,(j-1))
		
			Duplicate/O/R=[boundary1+1,boundary0] Index_Sorted, $("Index_"+ num2str(j))
			Duplicate/O/R=[boundary1+1,boundary0] PC1_Sorted $("PC1_"+ num2str(j))
			Duplicate/O/R=[boundary1+1,boundary0] PC2_Sorted $("PC2_"+ num2str(j))
			Duplicate/O/R=[boundary1+1,boundary0] PC3_Sorted $("PC3_"+ num2str(j))
			WMXYZToXYZTriplet($("PC1_"+ num2str(j)),$("PC2_"+ num2str(j)),$("PC3_"+ num2str(j)), ("xyzPC"+num2str(j)))
			string/G temp="xyzPC"+num2str(j)
			string/G scatNum="scatter"+(num2str((Wavemax(Index)-j)))
			string/G cFrac
			sprintf cFrac,"ModifyGizmo ModifyObject=%s, property={color,%g,%g,%g,0}", scatNum, (M_colors[cIndex*j][0])/65535,(M_colors[cIndex*j][1])/65535,(M_colors[cIndex*j][2])/65535
			Execute "AppendToGizmo nextscatter=$temp"
			Execute "ModifyGizmo ModifyObject=$scatNum property={shape,1}"
			Execute "ModifyGizmo ModifyObject=$scatNum property={size,3}"			
			Execute cFrac
			Execute "ModifyGizmo showAxisCue = 1"
			KillStrings temp, scatnum, cFrac
			
			Variable k=0   //begin Addition for Overlayed spikes
			string/G spkList=WaveList("Event_*",";","")
			
			j-=1
	
		while (j>=0)		
	SetDataFolder fldrSav0
End

Function tSort_ExportGizmo(ctrlName) : ButtonControl
	String ctrlName
	
	String StrFileType
	Prompt StrFileType, "Which File Type?", popup, "bmp;EPS;"
	DoPrompt "Select Extensions", StrFileType
	If(V_flag)
		Abort
	EndIf
	
	String t = ""
	
	strswitch(StrFileType)
		case "bmp":
			t = "ExportGizmo as \"\""
			break
		case "EPS":
			t = "ExportGizmo EPS"
			break
		default:
			break
	endswitch

	Execute t
End

///////////////////////////////////////////////////////////////////////////
//Main Graph

Function tSort_MainGraph()
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		Display/N=tSortMainGraph/W=(354.75,198.5,949.5,461) MainGraphSampleWave
		ModifyGraph margin(left)=85,margin(bottom)=43,margin(right)=28,margin(top)=50,width=481.89
		ModifyGraph height=170.079
		ModifyGraph axisEnab(left)={0,0.85}
	SetDataFolder fldrSav0
	
	//P0 (upper)
	SetDrawLayer UserFront
	DefineGuide UGV0={PR,1,GR},UGH0={FB,-93.75},UGV1={FL,0}
	NewPanel/W=(0,0.042,1,0.15)/FG=(,FT,,PT)/HOST=# 
	SetDrawLayer UserBack
	ValDisplay ValbitDispMode,pos={18,12},size={95,13},title="bitDispMode",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:tSort:bitDispMode"
	TitleBox TitleWaveName,pos={16,27},size={57,20},variable= root:Packages:tSort:tWaveSort
	Button BtClearMainGraphIndexXLock,pos={120,10},size={100,20},proc=tSortClearIndexXLockMainGraph,title="ClearIndexXLock"
	Button BtMainGraphIndexColorScale,pos={120,30},size={70,20},proc=tSort_MainGraphIndexColorScale,title="ScaleColor"
	Button BtAutoScale,pos={190,30},size={70,20},proc=tSort_AutoScaletSortMainGraph,title="AutoScale"
	Button BtFocusEventSerial,pos={268,10},size={70,20},proc=tSort_MainGraphFocusEvent,title="FocusEvent"
	SetVariable SetVarFocusWindow,pos={271,34},size={130,16},title="Focus Window",limits={0.001,inf,0.001},value= root:Packages:tSort:FocusWindow
	GroupBox GroupMarquee,pos={411,8},size={150,50},title="Marquee"
	Button BtMarqueeAdd,pos={412,28},size={50,20},proc=tSort_AutoSearch,title="Add"
	Button BtMarqueeDelete,pos={487,28},size={50,20},proc=tSort_MarqueeDelete,title="Delete"
	SetVariable SetGraphHeight,pos={574,10},size={130,16},proc=tSort_ModifiyGraphHeight,title="GraphHeight (cm)",limits={1,inf,1},value= root:Packages:tSort:GraphHeight
	Button BttSortMainGraphPreSweep,pos={583,33},size={50,20},proc=tSort_MainGraph_PreNextSweep,title="Pre Sw"
	Button BttSortMainGraphNextSweep,pos={638,33},size={50,20},proc=tSort_MainGraph_PreNextSweep,title="Next Sw"
	Button BtMainGraphBurst,pos={715,8},size={65,20},proc=tSort_UpdateBandNBLabelWaves,title="BurstIndex"
	CheckBox CheckMainGraphFirstOnly,pos={714,36},size={69,14},title="First Only",value= 0

	RenameWindow #,P0
	SetActiveSubwindow ##

	//P1 (bottom)
//	NewPanel/W=(0.2,0.885,1,0.8)/FG=(FL,,,FB)/HOST=# 
	
//	RenameWindow #,P1
//	SetActiveSubwindow ##
end

Function tSort_DisplayMainGraph()
	If(WinType("tSortMainGraph") == 1)
		DoWindow/HIDE = ? $("tSortMainGraph")
		If(V_flag == 1)
			DoWindow/HIDE = 1 $("tSortMainGraph")
		else
			DoWindow/HIDE = 0/F $("tSortMainGraph")
		endif
	else	
		tSort_MainGraph()
	endif
End

Function tSort_HideMainGraph()
	If(WinType("tSortMainGraph"))
		DoWindow/HIDE = 1 $("tSortMainGraph")
	endif
End

Function tSortClearIndexXLockMainGraph(ctrlName) : ButtonControl
	String ctrlName
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:

		Wave MainGraphIndex, MainGraphXLock
		Redimension/n=0 MainGraphIndex, MainGraphXLock
	
	SetDataFolder fldrSav0
End

Function tSort_MainGraphIndexColorScale(ctrlName) : ButtonControl
	String ctrlName
	
	SVAR tWaveSort = root:Packages:tSort:tWaveSort
	NVAR bitDispMode = root:Packages:tSort:bitDispMode
	
	tSort_CopyLabelWave(0, tWaveSort)
	
	tSort_UpdateLabelWave()
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		Wave Index, MainGraphIndex, MainGraphBIndex, MainGraphNBIndex, MainGraphXLock
		Variable IndexMax=Wavemax(Index)
//		Variable IndexMax = MainGraphIndex
		
		If(bitDispMode & 2^5)
			If(numtype(IndexMax) ==2 || IndexMax == 0)
				ModifyGraph/W=tSortMainGraph zColor(MainGraphIndex)=0
			else
				SetAxis/W=tSortMainGraph IndexAxis -inf, +inf
				ModifyGraph/W=tSortMainGraph  zColor(MainGraphIndex)={MainGraphIndex,*,IndexMax,Rainbow256,0}
			endIf
		endIf
		
		If(bitDispMode & 2^6)
			If(numtype(IndexMax) ==2 || IndexMax == 0)
				ModifyGraph/W=tSortMainGraph zColor(MainGraphBIndex)=0
			else
				SetAxis/W=tSortMainGraph BIndexAxis -inf, +inf
				ModifyGraph/W=tSortMainGraph  zColor(MainGraphBIndex)={MainGraphBIndex,*,IndexMax,Rainbow256,0}
			endIf
		endIf
			
		If(bitDispMode & 2^7)
			If(numtype(IndexMax) ==2 || IndexMax == 0)
				ModifyGraph/W=tSortMainGraph zColor(MainGraphNBIndex)=0
			else
				SetAxis/W=tSortMainGraph NBIndexAxis -inf, +inf
				ModifyGraph/W=tSortMainGraph  zColor(MainGraphNBIndex)={MainGraphNBIndex,*,IndexMax,Rainbow256,0}
			endIf
		endIf
	SetDataFolder fldrSav0
end

Function tSort_UpdateLabelWave()

	String fldrsav0 = GetDataFolder(1)
	SetDatafolder root:Packages:tSort:
		Wave XLock, Index
		Wave/T wvName, tSortListWave
		
		Variable i = 0, j = 0
		
		For(i = 0; i < Dimsize(tSortListWave, 0); i += 1)
			String StrSrcWave = tSortListWave[0][i]
			Make/n=0 tempXLock, tempIndex
			Wave tempXLock, tempIndex
			
			For(j = 0; j < numpnts(wvName); j += 1)
				If(StringMatch(wvName[j], StrSrcWave))
					Variable npnts = numpnts(tempXLock)
					InsertPoints npnts, 1, tempXLock, tempIndex
					tempXLock[npnts] = XLock[j]
					tempIndex[npnts] = Index[j]
				endIf
			endFor

			String LabelMainGraphIndex = StrSrcWave + "_MGIndex"
			String LabelMainGraphXLock = StrSrcWave + "_MGXLock"
			
			Wave wLabelMainGraphIndex = $LabelMainGraphIndex
			Wave wLabelMainGraphXLock = $LabelMainGraphXLock
			
			Duplicate/O tempXLock, wLabelMainGraphXLock
			Duplicate/O tempIndex, wLabelMainGraphIndex
			
			KillWaves tempXLock, tempIndex
		endFor
		
	SetDataFolder fldrsav0
end

Function tSort_AutoScaletSortMainGraph(ctrlName) : ButtonControl
	String ctrlName
	
	SetAxis/A bottom
	SetAxis/A left
	
	tSort_MainGraphIndexColorScale("")
End

Function tSort_MainGraphFocusEvent(ctrlName) : ButtonControl
	String ctrlName
	
	NVAR EventSerial = root:Packages:tSort:EventSerial
	NVAR FocusWindow = root:Packages:tSort:FocusWindow
	SVAR tWaveSort = root:Packages:tSort:tWaveSort
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		Wave XLock
		Wave/T wvName
	SetDataFolder fldrSav0
	
	If(StringMatch(wvName[EventSerial - 1], tWaveSort) == 0)
		tWaveSort = wvName[EventSerial - 1]
		tSort_ListWaveUpdate(tWaveSort)
		tSort_MainDisplayInitialize("")
	endIf

	SetAxis/W=tSortMainGraph bottom, (XLock[EventSerial - 1] - FocusWindow/2), (XLock[EventSerial - 1] + FocusWindow/2)
End

Function tSort_ListWaveUpdate(StrSpikeWave)
	String StrSpikeWave
	
	Wave/T ListWave = root:Packages:tSort:tSortListWave
	
	Variable i = 0
	
	For(i = 0; i < 1000; i += 1)
		If(StringMatch(ListWave[i][0], StrSpikeWave))
			break
		endIf
	endFor
	
	ListBox/Z SortWaveList_tab0 win=tSortMainControlPanel, selRow = i, row = i-10
End

Function tSort_MainGraph_PreNextSweep(ctrlName) : ButtonControl
	String ctrlName
	
	SVAR tWaveSort = root:Packages:tSort:tWaveSort
	Wave/T ListWave = root:Packages:tSort:tSortListWave
	ControlInfo/W=tSortMainControlPanel SortWaveList_tab0
	
	Variable NewRow
	
	StrSwitch(ctrlName)
		case "BttSortMainGraphPreSweep":
			NewRow = V_value - 1
			break
		case "BttSortMainGraphNextSweep":
			NewRow = V_value + 1
			break
		default:
			break
	endSwitch
	
	ListBox/Z SortWaveList_tab0 win=tSortMainControlPanel, selRow = (NewRow), row = (V_value)
	tWaveSort = ListWave[NewRow][0]
	DoUpdate
	
	tSort_MainDisplayInitialize("")
	
	tSort_MainGraphIndexColorScale("")	
end

Function tSort_UpdateBandNBLabelWaves(ctrlName) : ButtonControl
	String ctrlName

	SVAR tWaveSort = root:Packages:tSort:tWaveSort
	Wave/T ListWave = root:Packages:tSort:tSortListWave
	
	Variable npnts = Dimsize(ListWave, 1)
	Variable i = 0
	do		
		tSort_CopyLabelWave(0, ListWave[i][0])
		
		ControlInfo/W=tSortMainGraph#P0 CheckMainGraphFirstOnly
		If(V_Value)
			tSort_ExcecuteBandNBLabelWaves(ListWave[i][0], 1)
		else
			tSort_ExcecuteBandNBLabelWaves(ListWave[i][0], 0)
		endIf
		i += 1
	while(i < npnts)
	
	tSort_CopyLabelWave(0, tWaveSort)
	
	tSort_MainGraphIndexColorScale("")	
End

Function tSort_ExcecuteBandNBLabelWaves(StrLabel, var)
	String StrLabel
	Variable var

	String LabelMainGraphIndex = StrLabel + "_MGIndex"
	String LabelMainGraphBIndex = StrLabel + "_MGBIndex"
	String LabelMainGraphNBIndex = StrLabel + "_MGNBIndex"
	String LabelMainGraphXLock = StrLabel + "_MGXLock"
		
	String fldrsav0 = GetDataFolder(1)
	SetDatafolder root:Packages:tSort:
		Wave wLabelMainGraphIndex = $LabelMainGraphIndex
		Wave wLabelMainGraphBIndex = $LabelMainGraphBIndex
		Wave wLabelMainGraphNBIndex = $LabelMainGraphNBIndex
		Wave wLabelMainGraphXLock = $LabelMainGraphXLock
		Wave MainGraphIndex, MainGraphBIndex, MainGraphNBIndex, MainGraphXLock
		Wave Index, PatternIndex, Serial0
		Wave/T wvName
	SetDataFolder fldrsav0
	
	Duplicate/O MainGraphIndex, MainGraphBIndex
	Duplicate/O MainGraphIndex, MainGraphNBIndex
	
	Variable npnts = numpnts(MainGraphXLock)
	FindValue/TEXT=StrLabel wvName
	Variable startpnt = V_Value
	Variable i = 0

	do
		If(var)		// First bursts
			switch((PatternIndex[(startpnt + i)]))
				case 0:
					MainGraphBIndex[i] = NaN
					MainGraphNBIndex[i] = Index[(startpnt + i)]
					break
				case 1:
					MainGraphBIndex[i] = Index[(startpnt + i)]
					MainGraphNBIndex[i] = NaN
					break					
				default:
					MainGraphBIndex[i] = NaN
					MainGraphNBIndex[i] = NaN
					break
			endswitch
		else			// All burst
			switch((PatternIndex[(startpnt + i)]))
				case 0:
					MainGraphBIndex[i] = NaN
					MainGraphNBIndex[i] = Index[(startpnt + i)]
					break
				default:
					MainGraphBIndex[i] = Index[(startpnt + i)]
					MainGraphNBIndex[i] = NaN
					break
			endswitch
		endIf
		i += 1
	while(i < npnts)
	
	Duplicate/O MainGraphIndex, wLabelMainGraphIndex
	Duplicate/O MainGraphBIndex, wLabelMainGraphBIndex
	Duplicate/O MainGraphNBIndex, wLabelMainGraphNBIndex
	Duplicate/O MainGraphXLock, wLabelMainGraphXLock
End

///////////////////////////////////////////////////////////////////////////
//Event Graph

Function tSort_EventGraph(V_left, V_top, V_right, V_bottom)
	Variable V_left, V_top, V_right, V_bottom
	
	String fldrSav0= GetDataFolder(1)
//	SetDataFolder root:Packages:tSort:
	Display/N=tSortEventGraph/W=(V_left,V_top,V_right,V_bottom)
//	SetDataFolder fldrSav0
	ModifyGraph margin(left)=57,margin(bottom)=28,margin(top)=57,margin(right)=14,width=198.425
	ModifyGraph height=170.079
	DefineGuide UGV0={PR,1,GR},UGH0={FB,0},UGV1={FL,0}
	NewPanel/W=(0,0.042,1,0.225)/FG=(,FT,,PT)/HOST=#
	Button BtWindowDiscrimination,pos={15,3},size={65,20},proc=tSort_EventGraphWinDisc,title="WinDisc"
	Button BtWindowDelete,pos={15,23},size={65,20},proc=tSort_DoWindowDelete,title="WinDelete"
	GroupBox GrouptSortRange,pos={109,2},size={120,45},title="Spike Range (s)"
	SetVariable SettSortRange,pos={119,21},size={105,16},title="Range",limits={0.001,inf,0.0001},value= root:Packages:tSort:SpikeRange
	Button BtExtractEventWaves,pos={248,3},size={50,20},proc=tSort_ExtractEventWaves,title="Extract"
	Button BtClearEventWaves,pos={298,3},size={50,20},proc=tSort_CleartSortEventGraph,title="Clear"
	Button BtKillAllEventWaves,pos={298,23},size={50,20},proc=tSort_KillAllEvents,title="Kill"
	Button BtEventGraphEventColor,pos={248,23},size={50,20},proc=tSort_EventGraph_EventColor,title="Color"
	SetVariable SetvarEventSerial,pos={125,50},size={100,16},proc=tSort_UpdateEventSerial,title="EventSerial",limits={1,inf,1},value= root:Packages:tSort:EventSerial
	SetVariable SetvarEventIndex,pos={275,50},size={70,16},proc=tSort_UpdateIndexByEventIndex,title="Index",limits={0,inf,1},value= root:Packages:tSort:EventIndex
	
	RenameWindow #,P0
	SetActiveSubwindow ##
	
//	NewPanel/W=(0.2,0.885,1,0.8)/FG=(FL,,,FB)/HOST=#
//	RenameWindow #,P1
//	SetActiveSubwindow ##
end

Function tSort_DisplayEventGraph()
	If(WinType("tSortEventGraph") == 1)
		DoWindow/HIDE = ? $("tSortEventGraph")
		If(V_flag == 1)
			DoWindow/HIDE = 1 $("tSortEventGraph")
		else
			DoWindow/HIDE = 0/F $("tSortEventGraph")
		endif
	else	
		tSort_EventGraph(72.75,198.5,342,453.5)
	endif
End

Function tSort_HideEventGraph()
	If(WinType("tSortEventGraph"))
		DoWindow/HIDE = 1 $("tSortEventGraph")
	endif
End

Function tSort_EventGraphWinDisc(ctrlName) : ButtonControl
	String ctrlName
	
	Variable IndexNum = 0
	Prompt  IndexNum, "IndexNum?"
	DoPrompt "Define Index Num", IndexNum
	
	If(V_flag)
		Abort
	endIf
	
	tSort_DoWindowDisc(IndexNum)
End

Function tSort_DoWindowDisc(IndexNum)
	Variable IndexNum
	
	GetMarquee/W = tSortEventGraph bottom, left
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		Wave Index
		String EventWaveList = WaveList("!HighlightedEvent", ";", "WIN:")
		Variable i = 0
		
		do
			String SFL = StringFromList(i, EventWaveList)
			If(Strlen(SFL) < 1)
				break
			endIf
			Wave srcW = $SFL
			WaveStats/Q/R=(V_left, V_right) srcW
			If(V_min > V_top || V_max < V_bottom)
			
			else
				Variable EventIndex = 0
				sscanf SFL, "Event_%f", EventIndex
				Index[EventIndex - 1]  = IndexNum
			endIf
			i += 1		
		while(1)
	SetDataFolder fldrSav0
	
	 tSort_EventGraph_EventColor("")
	 
	 tSort_UpdateMasterLb2D()
	 
	 tSort_UpdateLableWave()
end

Function tSort_DoWindowDelete(ctrlName) : ButtonControl
	String ctrlName
	
	GetMarquee/W = tSortEventGraph bottom, left
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:

		String EventWaveList = WaveList("!HighlightedEvent", ";", "WIN:")
		Variable i = 0
		
		do
			String SFL = StringFromList(i, EventWaveList)
			If(Strlen(SFL) < 1)
				break
			endIf
			Wave srcW = $SFL
			WaveStats/Q/R=(V_left, V_right) srcW
			If(V_min > V_top || V_max < V_bottom)
			
			else
				RemoveFromGraph/W = tSortEventGraph $SFL
				Killwaves $SFL
				Variable EventIndex = 0
				sscanf SFL, "Event_%f", EventIndex
				tSort_DeleteEvent(EventIndex)
			endIf
			i += 1
		while(1)

	Wave Serial0
	SetDataFolder fldrSav0

	Serial0[p,] = x + 1
	
	tSort_adjustIEI()

	ControlInfo/W=tSortMasterTable Lb0
	If(V_value <10)
		ListBox Lb0, win=tSortMasterTable, row=-1, selRow= V_value-1
	else
		ListBox Lb0, win=tSortMasterTable, row=(V_value - 10), selRow= V_value-1
	endif

	tSort_ExtractEventWaves("")
	
	tSort_UpdateMasterLb2D()
	
	tSort_UpdateLableWave()
End

Function tSort_DeleteEvent(EventIndex)
	Variable EventIndex
	
	Variable i = 0
	String SFL = ""
	//T0のWavelist
	String fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		String T0WL = Wavelist("*", ";", "WIN:tSortMasterTable#T0")
		Wave Serial0
	SetDataFolder fldrsav0
	
	FindValue/V = (EventIndex) Serial0
	
	do
		SFL = StringFromList(i, T0WL)
		If(Strlen(SFL)<1)
			break
		endIf
		Deletepoints V_value, 1, $("root:Packages:tSort:" + SFL)
		i += 1
	while(1)
End

Function tSort_ExtractEventWaves(ctrlName) : ButtonControl
	String ctrlName
	
	Variable ticks0, ticks1
	ticks0 = ticks

	PauseUpdate
	
	NVAR SpikeRange = root:Packages:tSort:SpikeRange
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort
		Wave/T wvName
		Wave Serial0, XLock, Index
	SetDataFolder fldrSav0

	tSort_CleartSortEventGraph("")

	Variable i = 0
	String StrsrcW = wvName[i]
	Wave srcW = $StrsrcW
	Duplicate/O srcW, wtemp
	Wave wtemp
	Redimension/n=(SpikeRange/deltax(srcW)) wtemp
	DoWindow/F tSortEventGraph

	do
		Duplicate/O wtemp, root:Packages:tSort:$("Event_" + Num2Str(i + 1))
		Wave destW = root:Packages:tSort:$("Event_" + Num2Str(i + 1))
		StrsrcW = wvName[i]
		Wave srcW = $StrSrcW
		destW[p, ] = srcW[p + x2pnt(srcW, XLock[i]) - (SpikeRange/2)/deltax(srcw)]
		AppendToGraph/W=tSortEventGraph destW
		i += 1
	while(i < numpnts(Serial0))

	Killwaves wtemp
	
	tSort_EventGraph_EventColor("")
	
	ResumeUpdate
	
	ticks1 = ticks
	Print (ticks1 - ticks0)/60, "s"
End

Function tSort_CleartSortEventGraph(ctrlName) : ButtonControl
	String ctrlName

	Variable i = 0
	String SFL = ""
	GetWindow tSortEventGraph, wsize
	KillWindow tSortEventGraph
	tSort_EventGraph(V_left, V_top, V_right, V_bottom)
	
//	String fldrSav0= GetDataFolder(1)
//	SetDataFolder root:Packages:tSort:
//		PauseUpdate
//		String StrList = WaveList("*", ";", "WIN:tSortEventGraph")
//		do
//			SFL = StringFromList(i, StrList)
//			If(strlen(SFL)<1)
//				break
//			endif
//			RemoveFromGraph/W=tSortEventGraph $SFL
//		while(1)
//		ResumeUpdate
//	SetDataFolder fldrSav0
End


Function tSort_KillAllEvents(ctrlName) : ButtonControl
	String ctrlName

	DoAlert 2, "All Event Waves are going to be killed.\nAre you going to  continue?"
	If(V_Flag != 1)
		Abort
	endIf

	tSort_CleartSortEventGraph("")	

	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		String SFL = ""
		String WL = Wavelist("Event_*",";","")
		Variable i = 1
		do
			SFL = StringFromList(i, WL)
			If(strlen(SFL)<1)
				break
			endif
			Wave tw = $SFL
			Killwaves tw
			i += 1
		while(1)
	SetDataFolder fldrSav0
End

Function tSort_EventGraph_EventColor(ctrlName) : ButtonControl
	String ctrlName
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:

		Wave Index
		Variable i = 0
		Variable npnts = numpnts(Index)
	 
		 do
		 	String StrEventWave = "Event_" + Num2str(i+1)
		 	Wave EventWave = $StrEventWave
			RemoveFromGraph/w=tSortEventGraph $StrEventWave
			AppendToGraph/T/C=(tSort_Rainbow256(Index[i], 0), tSort_Rainbow256(Index[i], 1), tSort_Rainbow256(Index[i], 2)) $StrEventWave
		 	i += 1
		 while(i < npnts)
		 		
	SetDataFolder fldrSav0
	
	tSort_ActivateHighlightedEvent()
end

Function tSort_Rainbow256(IndexValue, DimNum)
	Variable IndexValue, DimNum
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		Wave Index
		ColorTab2Wave Rainbow256
		Wave M_colors
		Variable IndexMax=Wavemax(Index)
		Variable cIndex=round(DimSize(M_colors,0)/IndexMax)
	SetDataFolder fldrSav0
		
	return M_colors[cIndex*IndexValue][DimNum]
end

Function tSort_ActivateHighlightedEvent()
	String fldrSav0= GetDataFolder(1)
	
//	Variable pfirst = Str2Num(StringFromList(0, StringByKey("SELECTION", TableInfo("tSortMasterTable#T0", -2), ":"), ","))
//	Variable plast = Str2Num(StringFromList(2, StringByKey("SELECTION", TableInfo("tSortMasterTable#T0", -2), ":"), ","))
	ControlInfo/w=tSortMasterTable Lb0
	
	SetDataFolder root:Packages:tSort:
		Wave HighlightedEvent
		String StrEventWaveTemp = "Event_" + Num2str(V_value + 1)
		Duplicate/O $StrEventWaveTemp, HighlightedEvent
		If(Strlen(WaveList("HighlightedEvent", ";", "WIN:tSortEventGraph"))>1)
			RemoveFromGraph/W=tSortEventGraph HighlightedEvent
		endif
		AppendToGraph/W=tSortEventGraph HighlightedEvent
		ModifyGraph/W=tSortEventGraph rgb(HighlightedEvent) = (0, 0, 0), lsize(HighlightedEvent)=1.5
	SetDataFolder fldrSav0
End

Function tSort_UpdateEventSerial(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	tSort_EventGraphHighlight(varNum)
	tSort_UpdateEventIndex()
	tSort_MasterTableHighlight(varNum)
End

Function tSort_EventGraphHighlight(EventSerial)
	Variable EventSerial
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		Wave HighlightedEvent
		String StrEventWaveTemp = "Event_" + Num2str(EventSerial)
		Duplicate/O $StrEventWaveTemp, HighlightedEvent
		If(Strlen(WaveList("HighlightedEvent", ";", "WIN:tSortEventGraph"))>1)
			RemoveFromGraph/W=tSortEventGraph HighlightedEvent
		endif
		AppendToGraph/W=tSortEventGraph HighlightedEvent
		ModifyGraph/W=tSortEventGraph rgb(HighlightedEvent) = (0, 0, 0), lsize(HighlightedEvent)=1.5
	SetDataFolder fldrSav0
End

Function tSort_UpdateEventIndex()
	NVAR EventIndex = root:Packages:tSort:EventIndex
	NVAR EventSerial = root:Packages:tSort:EventSerial
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		Wave Index
		
		EventIndex = Index[EventSerial - 1]
	SetDataFolder fldrSav0
End

Function tSort_MasterTableHighlight(EventSerial)
	Variable EventSerial

	If(EventSerial <10)
		ListBox Lb0, win=tSortMasterTable, row=-1, selRow= EventSerial-1
	else
		ListBox Lb0, win=tSortMasterTable, row=(EventSerial - 5), selRow= EventSerial-1
	endif
End

Function tSort_UpdateIndexByEventIndex(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	NVAR EventSerial = root:Packages:tSort:EventSerial

	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		Wave Index
		Index[EventSerial - 1] = varNum
	SetDataFolder fldrSav0
	
	tSort_UpdateMasterLb2D()
End

///////////////////////////////////////////////////////////////////////////
//Master Table

Function tSort_MasterTable()
	NewPanel/N=tSortMasterTable/W=(96,654,1267,898)
	Button BtMasterTablePrep,pos={2,6},size={70,20},proc=tSort_MasterTablePrep,title="TablePrep"
	Button BtMasterTable_ShowT0,pos={102,6},size={50,20},proc=tSort_MasterTableShowT0,title="T0"
	Button BtMasterTable_ListBox,pos={160,6},size={50,20},proc=tSort_MasterTableListBox,title="ListBox"
	Button BtEditT0MasterTable,pos={2,26},size={50,20},proc=tSort_EditT0MasterTable,title="EditT0"
	Button BtMasterTableDeletetWave,pos={229,6},size={100,20},proc=tSort_MasterTbDeletetWaveSort,title="Delete tWaveSort"
	Button BtMasterTableDelSelectedRecord,pos={330,6},size={100,20},proc=tSort_MasterDeleteSelRec,title="Delete Selected"
	Button BtMasterTableAllDelete,pos={432,6},size={90,20},proc=tSort_MasterTableDeleteAllPoint,title="DeleteAllPoints"
	Button BtMasterTableIndexedIEI,pos={630,6},size={70,20},proc=tSort_CalcIndexedIEI,title="IndexedIEI"
	Button BtMasterTablePatternIndex,pos={710,6},size={70,20},proc=tSort_CalcPatternIndex,title="PatternIndex"

	ListBox Lb0,pos={3,48},size={1165,194},frame=2,listWave=root:Packages:tSort:tSortMasterLb2D
	ListBox Lb0,row= 17,mode= 1,selRow= 0
//	ShowTools/A
	DefineGuide UGH0={FT,116}
	Edit/W=(77,216,745,301)/FG=(FR,FB,FR,FB)/HOST=#  as "tSortMasterTable"
	ModifyTable format=1, width=70
	ModifyTable statsArea=85
	RenameWindow #,T0
	SetActiveSubwindow ##
end

Function tSort_DisplayMasterTable()
	If(WinType("tSortMasterTable") == 7)
		DoWindow/HIDE = ? $("tSortMasterTable")
		If(V_flag == 1)
			DoWindow/HIDE = 1 $("tSortMasterTable")
		else
			DoWindow/HIDE = 0/F $("tSortMasterTable")
		endif
	else	
		tSort_MasterTable()
	endif
End

Function tSort_HideMasterTable()
	If(WinType("tSortMasterTable"))
		DoWindow/HIDE = 1 $("tSortMasterTable")
	endif
End

Function tSort_EditT0MasterTable(ctrlName) : ButtonControl
	String ctrlName
	
	String fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
	String tWavelist = Wavelist("*", ";", "WIN:tSortMasterTable#T0")
	Variable i = 0
	Edit
	String SFL
	do
		SFL = StringFromList(i, tWavelist)
		If(Strlen(SFL) < 1)
			break
		endIf
		AppendToTable $SFL
		i += 1
	while(1)
	SetDataFolder fldrsav0
End

Function tSort_MasterTableShowT0(ctrlName) : ButtonControl
	String ctrlName
	MoveSubwindow/W=tSortMasterTable#T0 fguide = (FL, UGH0, FR, FB)
	ListBox Lb0 disable=1, win=tSortMasterTable
End

Function tSort_MasterTableListBox(ctrlName) : ButtonControl
	String ctrlName
	MoveSubwindow/w=tSortMasterTable#T0 fguide = (FR, FB, FR, FB)
	ListBox Lb0 disable=0, win=tSortMasterTable
End


Function tSort_MasterTbDeletetWaveSort(ctrlName) : ButtonControl
	String ctrlName
	
	Variable i, j
	Wave Serial0 = root:Packages:tSrot:Serial0
	Wave/T wvName = root:Packages:tSort:wvName
	Variable n = numpnts(Serial0)
	SVAR tWaveSort = root:Packages:tSort:tWaveSort
	String SFL = ""
	//T0のWavelist
	String fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		String T0WL = Wavelist("*", ";", "WIN:tSortMasterTable#T0")
		j = 0
		do
			If(StringMatch(wvName[j], tWaveSort))
				i = 0
				do
					SFL = StringFromList(i, T0WL)
					If(Strlen(SFL)<1)
						i += 10000
					else
						Deletepoints j, 1, $SFL
					endIf
					i += 1
				while(i < 10000)
			endIf
			j += 1
		while(j <= n)
	SetDataFolder fldrsav0
	
	tSort_adjustIEI()
	
	tSort_UpdateMasterLb2D()
	
	Variable npnts = numpnts(Serial0)
	If(npnts <10)
		ListBox Lb0, win=tSortMasterTable, row=-1, selRow= npnts-1
	else
		ListBox Lb0, win=tSortMasterTable, row=(npnts - 10), selRow= npnts-1
	endif
	
	tSort_UpdateLableWave()
	
	tSort_ExtractEventWaves("")
End


Function tSort_MasterDeleteSelRec(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo/W=tSortMasterTable Lb0
	Switch(V_disable)
		case 0:
			Variable pfirst = V_value
			Variable plast = V_value
			break
		case 1:
			pfirst = Str2Num(StringFromList(0, StringByKey("SELECTION", TableInfo("tSortMasterTable#T0", -2), ":"), ","))
			plast = Str2Num(StringFromList(2, StringByKey("SELECTION", TableInfo("tSortMasterTable#T0", -2), ":"), ","))
			break
		case 2:
			break
	endSwitch

	Variable i = 0
	String SFL = ""
	//T0のWavelist
	String fldrsav0 = GetDataFolder(1)
		SetDataFolder root:Packages:tSort:
		String T0WL = Wavelist("*", ";", "WIN:tSortMasterTable#T0")
	SetDataFolder fldrsav0
	do
		SFL = StringFromList(i, T0WL)
		If(Strlen(SFL)<1)
			break
		endIf
		Deletepoints pfirst, (plast-pfirst+1), $("root:Packages:tSort:" + SFL)
		i += 1
	while(1)
	
	Wave Serial0 = root:Packages:tSort:Serial0
	Serial0[p,] = x + 1
	
	tSort_adjustIEI()
	
//	Variable InsertingPoint = DeletingPoint
//	EventSerial = InsertingPoint + 1
//	Variable point = InsertingPoint	
	
	tSort_UpdateMasterLb2D()
	
//	Variable npnts = numpnts(Serial0)
//	If(npnts <10)
//		ListBox Lb0, win=tSortMasterTable, row=-1, selRow= npnts-1
//	else
//		ListBox Lb0, win=tSortMasterTable, row=(npnts - 10), selRow= npnts-1
//	endif

	ControlInfo/W=tSortMasterTable Lb0
	If(V_value <10)
		ListBox Lb0, win=tSortMasterTable, row=-1, selRow= V_value-1
	else
		ListBox Lb0, win=tSortMasterTable, row=(V_value - 10), selRow= V_value-1
	endif
	
	tSort_UpdateLableWave()
	
	tSort_ExtractEventWaves("")
End

Function tSort_MasterTableDeleteAllPoint(ctrlName) : ButtonControl
	String ctrlName
	String fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:tSort
		Wave Serial = root:Packages:tSort:Serial0
		String tWavelist = Wavelist("*", ";", "WIN:tSortMasterTable#T0")
		Variable i = 0
		DoAlert 2, "All data in this table will be deleted.\nAre you going to  continue?"
		If(V_Flag != 1)
			Abort
		endIf
	
		String SFL = ""
		Variable n = numpnts(Serial0)
		do
			SFL = StringFromList(i, tWavelist)
			If(Strlen(SFL) < 1)
				break
			endIf
			DeletePoints 0, n, $SFL
			i += 1
		while(1)
	SetDataFolder fldrsav0
	
	 tSort_UpdateMasterLb2D()
	 
	 tSort_UpdateLableWave()
End

Function tSort_CalcIndexedIEI(ctrlName) : ButtonControl
	String ctrlName
	
	String fldrsav0 = GetDataFolder(1)
	SetDatafolder root:Packages:tSort:
		Wave  XLock, Index, IndexedIEI
		Wave/T wvName
	SetDataFolder fldrsav0
	
	Variable i, j, IndexMax, numIndex
	WaveStats/Q/M=1 Index
	IndexMax = V_max
	numIndex = numpnts(Index)
	
	i = 0
	do
		j = 0
		Variable jpre, j0, j1
		jpre = 0; j0 = 0; j1 = 0;
		do
			If(j == 0)
				FindValue/V=(i)/S=(j) Index
				If(V_Value == -1)
					break
				endIf
				j0 = V_Value
				IndexedIEI[j0] = NaN
			else
				If(StringMatch(wvName[jpre], wvName[j0]))
					IndexedIEI[j0] = XLock[j0] - XLock[jpre]
				endIf
			endIf
			
			FindValue/Z/V=(i)/S=(j0+1) Index
			If(V_Value == -1)
				break
			endIf
			j1 = V_Value
	
			jpre = j0
			j0 = j1
			j = j1 
		while(j < numIndex)
		i += 1
	while(i <= IndexMax)
	
	tSort_UpdateMasterLb2D()
End

Function tSort_CalcPatternIndex(ctrlName) : ButtonControl
	String ctrlName

	NVAR PreBurstIEI = root:Packages:tSort:PreBurstIEI
	NVAR BurstStartIEI = root:Packages:tSort:BurstStartIEI
	NVAR BurstEndIEI = root:Packages:tSort:BurstEndIEI

	String fldrsav0 = GetDataFolder(1)
	SetDatafolder root:Packages:tSort:
		Wave  Index, IndexedIEI, PatternIndex
		Wave/T wvName
		String T0WL = Wavelist("*", ";", "WIN:tSortMasterTable#T0")
	SetDataFolder fldrsav0
	
	Variable i, j, IndexMax, numIndex
	WaveStats/Q/M=1 Index
	IndexMax = V_max
	numIndex = numpnts(Index)
	
	i = 0
	do
		j = 0
		Variable jpre, j0, j1
		jpre = 0; j0 = 0; j1 = 0;
		do
			If(j == 0)
				FindValue/Z/V=(i)/S=(j) Index
				jpre = NaN
				FindValue/Z/V=(i)/S=(j) Index
				If(V_Value == -1)
					break
				endIf
				j0 = V_Value
			endIf
			
			FindValue/Z/V=(i)/S=(j0+1) Index
			j1 = V_Value
				
			If(StringMatch(wvName[jpre], wvName[j0]))
				
			endIf

			If(IndexedIEI[j0] > PreBurstIEI)
				If(IndexedIEI[j1] < BurstStartIEI)
					PatternIndex[j0] = 1
				else
					PatternIndex[j0] = 0
				endIf
			elseif(IndexedIEI[j1] < BurstEndIEI)
				If(numtype(IndexedIEI[j0]) == 2)
					If(IndexedIEI[j1] < BurstStartIEI)
						PatternIndex[j0] = 1
					else	
						PatternIndex[j0] = 0
					endIf
				else
					If(StringMatch(wvName[jpre], wvName[j0]))
						PatternIndex[j0] = PatternIndex[jpre] + 1
					else
						If(IndexedIEI[j1] < BurstStartIEI)
							PatternIndex[j0] = 1
						else
							PatternIndex[j0] = 0
						endIf
					endIf
				endIf
			else
				If(numtype(IndexedIEI[jpre]) == 2)
					If(numtype(IndexedIEI[j0]) == 2)
						If(IndexedIEI[j0] < BurstStartIEI)
							PatternIndex[j0] = PatternIndex[jpre] + 1
						else
							PatternIndex[j0] = 0
						endIf
					else
						PatternIndex[j0] = PatternIndex[jpre] + 1
					endIf
				else
					If(IndexedIEI[j0] < BurstStartIEI)
						PatternIndex[j0] = PatternIndex[jpre] + 1
					else
						PatternIndex[j0] = 0
					endIf
				endIf
			endIf
				
			jpre = j0
			j0 = j1
			j = j1 
		while(j > 0 && j < numIndex)
		i += 1
	while(i <= IndexMax)
	
	tSort_UpdateMasterLb2D()
End


Function tSort_UpdateLableWave()
	SVAR tWaveSort = root:Packages:tSort:tWaveSort
	String LabelMainGraphIndex = tWaveSort + "_MGIndex"
	String LabelMainGraphXLock = tWaveSort + "_MGXLock"
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		Wave wLabelMainGraphIndex = $LabelMainGraphIndex
		Wave wLabelMainGraphXLock = $LabelMainGraphXLock
		Wave MainGraphIndex, MainGraphXLock, Index, XLock
		Wave/T wvName
		
		Variable i = 0
		Redimension/n=0, wLabelMainGraphIndex, wLabelMainGraphXLock
		do
			Variable npnts = numpnts(wLabelMainGraphIndex)+1
			If(StringMatch(wvName[i], tWaveSort))
				Insertpoints npnts, 1, wLabelMainGraphIndex, wLabelMainGraphXLock
				wLabelMainGraphIndex[npnts] = Index[i]
				wLabelMainGraphXLock[npnts] = XLock[i]
			endIf
			i += 1
		while(i < numpnts(wvName))
	
		Duplicate/O wLabelMainGraphIndex, MainGraphIndex
		Duplicate/O wLabelMainGraphXLock, MainGraphXLock
	SetDataFolder fldrSav0
end

///////////////////////////////////////////////////////////////////////////
//Slave Table

Function tSort_SlaveTable()
	NewPanel/N=tSortSlaveTable/W=(12,686,1193,930)
	Button BtSlaveTablePrep,pos={1,6},size={70,20},proc=tSort_SlaveTablePrep,title="TablePrep"
	Button BtEditT0SlaveTable,pos={2,26},size={50,20},proc=tSort_EditT0SlaveTable,title="EditT0"
	Button BtSlaveTable_ShowT0,pos={94,6},size={50,20},proc=tSort_SlaveTableShowT0,title="T0"
	Button BtSlaveTable_ListBox,pos={146,6},size={50,20},proc=tSort_SlaveTableListBox,title="ListBox"
	Button BtSlaveTableDeletetWave,pos={210,6},size={100,20},proc=tSort_SlaveTbDeletetWaveSort,title="Delete tWaveSort"
	Button BtSlaveTableDelSelectedRecord,pos={310,6},size={100,20},proc=tSort_SlaveDeleteSelRec,title="Delete Selected"
	Button BtSlaveTableAllDelete,pos={410,6},size={90,20},proc=tSort_SlaveTableDeleteAllPoint,title="DeleteAllPoints"
	Button BtSlaveTableBurstIndex,pos={516,6},size={60,20},proc=tSort_SlaveTableBurstIndex,title="BurstIndex"

	
	ListBox Lb0,pos={3,48},size={1165,194},frame=2,listWave=root:Packages:tSort:tSortSlaveLb2D
	ListBox Lb0,row= 17,mode= 1,selRow= 0
//	ShowTools/A
	DefineGuide UGH0={FT,116}
	Edit/W=(77,216,745,301)/FG=(FR,FB,FR,FB)/HOST=#  as "tSortSlaveTable"
	ModifyTable format=1, width=70
	ModifyTable statsArea=85
	RenameWindow #,T0
	SetActiveSubwindow ##
end

Function tSort_DisplaySlaveTable()
	If(WinType("tSortSlaveTable") == 7)
		DoWindow/HIDE = ? $("tSortSlaveTable")
		If(V_flag == 1)
			DoWindow/HIDE = 1 $("tSortSlaveTable")
		else
			DoWindow/HIDE = 0/F $("tSortSlaveTable")
		endif
	else	
		tSort_SlaveTable()
	endif
End

Function tSort_HideSlaveTable()
	If(WinType("tSortSlaveTable"))
		DoWindow/HIDE = 1 $("tSortSlaveTable")
	endif
End

Function tSort_EditT0SlaveTable(ctrlName) : ButtonControl
	String ctrlName
	String fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
	String tWavelist = Wavelist("*", ";", "WIN:tSortSlaveTable#T0")
	Variable i = 0
	Edit
	String SFL
	do
		SFL = StringFromList(i, tWavelist)
		If(Strlen(SFL) < 1)
			break
		endIf
		AppendToTable $SFL
		i += 1
	while(1)
	SetDataFolder fldrsav0
End

Function tSort_SlaveTableShowT0(ctrlName) : ButtonControl
	String ctrlName
	MoveSubwindow/W=tSortSlaveTable#T0 fguide = (FL, UGH0, FR, FB)
	ListBox Lb0 disable=1, win=tSortSlaveTable
End

Function tSort_SlaveTableListBox(ctrlName) : ButtonControl
	String ctrlName
	MoveSubwindow/w=tSortSlaveTable#T0 fguide = (FR, FB, FR, FB)
	ListBox Lb0 disable=0, win=tSortSlaveTable
End


Function tSort_SlaveTbDeletetWaveSort(ctrlName) : ButtonControl
	String ctrlName
	
	Variable i, j
	SVAR tWaveSort = root:Packages:tSort:tWaveSort
	String SFL = ""
	//T0のWavelist
	String fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		Wave Serial1
		Wave/T wvNameSlave
		String T0WL = Wavelist("*", ";", "WIN:tSortSlaveTable#T0")
		j = 0
		do
			If(StringMatch(wvNameSlave[j], tWaveSort))
				i = 0
				do
					SFL = StringFromList(i, T0WL)
					If(Strlen(SFL)<1)
						break
					endIf
					
					Deletepoints j, 1, $SFL
					i += 1
				while(1)
			endIf
			j += 1
		while(j <= numpnts(Serial1))
	SetDataFolder fldrsav0
	
	tSort_UpdateSlaveLb2D()
	
	Variable npnts = numpnts(Serial1)
	If(npnts <10)
		ListBox Lb0, win=tSortSlaveTable, row=-1, selRow= npnts-1
	else
		ListBox Lb0, win=tSortSlaveTable, row=(npnts - 10), selRow= npnts-1
	endif
End


Function tSort_SlaveDeleteSelRec(ctrlName) : ButtonControl
	String ctrlName
	
	ControlInfo/W=tSortSlaveTable Lb0
	Switch(V_disable)
		case 0:
			Variable pfirst = V_value
			Variable plast = V_value
			break
		case 1:
			pfirst = Str2Num(StringFromList(0, StringByKey("SELECTION", TableInfo("tSortSlaveTable#T0", -2), ":"), ","))
			plast = Str2Num(StringFromList(2, StringByKey("SELECTION", TableInfo("tSortSlaveTable#T0", -2), ":"), ","))
			break
		case 2:
			break
	endSwitch
	
	Variable i = 0
	String SFL = ""
	//T0のWavelist
	String fldrsav0 = GetDataFolder(1)
		SetDataFolder root:Packages:tSort:
		String T0WL = Wavelist("*", ";", "WIN:tSortSlaveTable#T0")
	SetDataFolder fldrsav0
	do
		SFL = StringFromList(i, T0WL)
		If(Strlen(SFL)<1)
			break
		endIf
		Deletepoints pfirst, (plast-pfirst+1), $("root:Packages:tSort:" + SFL)
		i += 1
	while(1)
	
	Wave Serial1 = root:Packages:tSort:Serial1
	Serial1[p,] = x + 1
	
//	Variable InsertingPoint = DeletingPoint
//	EventSerial = InsertingPoint + 1
//	Variable point = InsertingPoint	
	
	tSort_UpdateSlaveLb2D()
	
	Variable npnts = numpnts(Serial1)
	If(npnts <10)
		ListBox Lb0, win=tSortSlaveTable, row=-1, selRow= npnts-1
	else
		ListBox Lb0, win=tSortSlaveTable, row=(npnts - 10), selRow= npnts-1
	endif
End

Function tSort_SlaveTableDeleteAllPoint(ctrlName) : ButtonControl
	String ctrlName
	String fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:tSort:
		Wave Serial = root:Packages:tSort:Serial1
		String tWavelist = Wavelist("*", ";", "WIN:tSortSlaveTable#T0")
		Variable i = 0
		DoAlert 2, "All data in this table will be deleted.\nAre you going to  continue?"
		If(V_Flag != 1)
			Abort
		endIf
	
		String SFL = ""
		Variable n = numpnts(Serial1)
		do
			SFL = StringFromList(i, tWavelist)
			If(Strlen(SFL) < 1)
				break
			endIf
			DeletePoints 0, n, $SFL
			i += 1
		while(1)
	SetDataFolder fldrsav0
	
	 tSort_UpdateSlaveLb2D()
End

Function tSort_SlaveTableBurstIndex(ctrlName) : ButtonControl
	String ctrlName

	String fldrsav0 = GetDataFolder(1)
	SetDatafolder root:Packages:tSort:
		Wave IndexSlave, PatternIndexSlave, BurstIndexSlave, NonBurstIndexSlave
	SetDataFolder fldrsav0
	
	Variable i = 0	
	do
		ControlInfo/W=tSortMainGraph#P0 CheckMainGraphFirstOnly
		If(V_Value)
			switch(PatternIndexSlave[i])
				case 0:
					BurstIndexSlave[i] = NaN
					NonBurstIndexSlave[i] = IndexSlave[i]
					break
				case 1:
					BurstIndexSlave[i] = IndexSlave[i]
					NonBurstIndexSlave[i] = NaN
					break					
				default:
					BurstIndexSlave[i] = NaN
					NonBurstIndexSlave[i] = NaN
					break
			endswitch
		else
			switch((PatternIndexSlave[i]))
				case 0:
					BurstIndexSlave[i] = NaN
					NonBurstIndexSlave[i] = IndexSlave[i]
					break
				default:
					BurstIndexSlave[i] = IndexSlave[i]
					NonBurstIndexSlave[i] = NaN
					break
			endswitch
		endIf

		i += 1	
	While(i < numpnts(BurstIndexSlave))
	
	tSort_ControlSlaveTableLb0(numpnts(BurstIndexSlave))
	
	tSort_UpdateSlaveLb2D()
End

Function tSort_UpdateSlaveLb2D()
	Variable vnpnts = numpnts(root:Packages:tSort:Serial1)
	
	String fldrsav0 = GetDataFolder(1)
	SetDatafolder root:Packages:tSort:
		Wave MainGraphXLock
		Wave Serial1, TimeLocked, Trial, IndexSlave, PatternIndexSlave, BurstIndexSlave, NonBurstIndexSlave, SerialRef, Trigger
		Wave/T wvNameSlave, tSortSlaveLb2D
	SetDataFolder fldrsav0

	Redimension/N=(vnpnts, 16) tSortSlaveLb2D
	
	tSortSlaveLb2D[][%Serial1]=Num2str(Serial1[p])
	
	tSortSlaveLb2D[][%wvNameSlave]=wvNameSlave[p]
	
	tSortSlaveLb2D[][%TimeLocked]=Num2str(TimeLocked[p])
	
	tSortSlaveLb2D[][%Trial]=Num2str(Trial[p])
	
	tSortSlaveLb2D[][%IndexSlave]=Num2str(IndexSlave[p])
	
	tSortSlaveLb2D[][%PatternIndex]=Num2str(PatternIndexSlave[p])
	
	tSortSlaveLb2D[][%BurstIndex]=Num2str(BurstIndexSlave[p])
	
	tSortSlaveLb2D[][%NonBurstIndex]=Num2str(NonBurstIndexSlave[p])
	
	tSortSlaveLb2D[][%SerialRef]=Num2str(SerialRef[p])
	
	tSortSlaveLb2D[][%Trigger]=Num2str(Trigger[p])
end
///////////////////////////////////////////////////////////////////////////
//Help


///////////////////////////////////////////////////////////////////////////
//Test

Function tSort_ModifyIndexPC()
	
	String fldrsav0 = GetDataFolder(1)
	SetDatafolder root:Packages:tSort:
		Wave Index, PC1, PC2, PC3
		Variable i = 0
		
		For(i = 0; i < numpnts(Index); i += 1)
			If(PC1[i] < -0.01)
				Index[i] = 1
			else
				Index[i] = 0
			endIf
		endFor

	SetDataFolder fldrsav0
end


///////////////////////////////////////////////////////////////////////////
//Utility

Function tSort_BitEncoder(bit0, bit1, bit2, bit3, bit4, bit5, bit6, bit7)
	Variable bit0, bit1, bit2, bit3, bit4, bit5, bit6, bit7
	
	Variable vOut = 0

	bit0 = trunc(bit0)
	If(bit0)
		vOut += 2^0
	endif
	
	bit1 = trunc(bit1)
	If(bit1)
		vOut += 2^1
	endif
	
	bit2 = trunc(bit2)
	If(bit2)
		vOut += 2^2
	endif
	
	bit3 = trunc(bit3)
	If(bit3)
		vOut += 2^3
	endif

	bit4 = trunc(bit4)
	If(bit4)
		vOut += 2^4
	endif

	bit5 = trunc(bit5)
	If(bit5)
		vOut += 2^5
	endif

	bit6 = trunc(bit6)
	If(bit6)
		vOut += 2^6
	endif

	bit7 = trunc(bit7)
	If(bit7)
		vOut += 2^7
	endif

	return vOut
end
