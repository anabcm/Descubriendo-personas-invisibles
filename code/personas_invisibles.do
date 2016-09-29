//Pasar bases de datos a dormato .csv para que los dem‡s puedan procesarla
foreach x in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 { 
use "/Users/GabrielaMarquezUCMex/Desktop/intercensal/eic2015_`x'_dta/Tr_persona`x'.dta", clear
drop  nom_ent nom_mun nom_loc parent_otro_c_e ent_pais_nac_e qdialect_inali_e ent_pais_asi_e ent_pais_res10_e ocupacion_c_e actividades_c_e ent_pais_trab_e
export delimited using "/Volumes/Lexar/personal_`x'.csv", delimiter("|") replace
}
*
//Armar la base a nivel nacional que de nœmeros totales de personas que tienen y no acta de nacimiento (por municipio)
foreach x in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 { 
use "/Users/GabrielaMarquezUCMex/Desktop/intercensal/eic2015_`x'_dta/Tr_persona`x'.dta", clear
gen act_nac_1=.
replace act_nac_1=1 if acta_nac==1
gen act_nac_2=.
replace act_nac_2=1 if acta_nac==2
gen act_nac_3=.
replace act_nac_3=1 if acta_nac==3
gen act_nac_9=.
replace act_nac_9=1 if acta_nac==9
collapse (sum) act_nac_1 act_nac_2 act_nac_3 act_nac_9, by(mun nom_mun ent nom_ent)
count
save "/Users/GabrielaMarquezUCMex/Desktop/Data/collapse/collapse_`x'.dta", replace
export delimited using "/Users/GabrielaMarquezUCMex/Desktop/Data/collapse/collapse_`x'.csv", delimiter("|") replace
}
*

global probit "/Users/GabrielaMarquezUCMex/Desktop/Data/

*PROBIT

//el modelo predictivo puede iterar en los 32 estados pero lo hice solo para  Chiapas (07),
	//se puede seleccionar un solo municipio (aqu’ se selecciona el "087")
	
*1. Preparaci—n de base de datos
foreach x in 07 { 
use "/Users/GabrielaMarquezUCMex/Desktop/intercensal/eic2015_`x'_dta/Tr_persona`x'.dta", clear
global probit "/Users/GabrielaMarquezUCMex/Desktop/Data/"

drop if acta_nac==3 | acta_nac==9
gen registro=.
replace registro=1 if acta_nac==1
replace registro=0 if acta_nac==2
count
generar variable identifica a quienes no hablan espa–ol
gen espanol=.
replace espanol=1 if hespanol==5
replace espanol=0 if hespanol==7

*generar variable madre es la jefa del hogar
gen jefa=.
replace jefa=1 if numper==1 & sexo==3
replace jefa=0 if missing(jefa)

*generar var hijo registrado
gen registro_nino=.
replace registro_nino=1 if registro==1 & parent==3
replace registro_nino=0 if registro==0 & parent==3

*gen variable indigena
gen indig=.
replace indig=1 if perte_indigena==1
replace indig=1 if perte_indigena==2
replace indig=0 if missing(indig)

destring loc50k, replace
destring mun, replace
destring parent_otro_c, replace

*sexo dicot—mico
gen genero=.
replace genero=1 if sexo==1
replace genero=0 if sexo==3

save "/Users/GabrielaMarquezUCMex/Desktop/Data/`x'_data.dta", replace
}
*

*2. Modelo Probit para Suchiate, Chiapas

use "/Users/GabrielaMarquezUCMex/Desktop/Data/07_data.dta", clear
set more off
global probit "/Users/GabrielaMarquezUCMex/Google Drive/"
keep if  mun=="087"
save "/Users/GabrielaMarquezUCMex/Desktop/Data/chiapas-suchiate.dta"

pprobit registro indig genero ident_madre ident_padre alfabet 
outreg2 using probit.doc, addstat (Log likelihood value, e(ll), Pseudo R2, e(r2_p), F, e( F ), p-value, e(p))

qui probit registro i.indig i.genero ident_madre ident_padre alfabet 
margins, dydx(*) atmean noatlegen
outreg2 using probit_EM.doc, addstat (Log likelihood value, e(ll), Pseudo R2, e(r2_p), F, e( F ), p-value, e(p))

qui probit registro i.indig i.genero ident_madre ident_padre alfabet 
estat classification
