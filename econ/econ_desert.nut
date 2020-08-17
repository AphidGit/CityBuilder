
require("econ.nut");
 class econ_desert extends econ{
 
 
 
    constructor() {	     
	    if(GSController.GetSetting("debug_level") > 1) {
	        GSLog.Info("Loading Tropic economy.");
	    }        
        // Cargo enable order, Needs to be overridden
        num_cargos = 6;
        enable_order = [9, 0, 11, 2, 5, 10];
        enable_populations = [200, 500, 1000, 2000, 3000, 5000];
        max_populations = [700, 1500, 2500, 4000, 6000, 7500];
        decay_rates = [50, 1000, 450, 1000, 250, 20];
        
        // 'Town accepted' absolute cargo amounts. Needs to be overridden
        accept_rel = [81, 80, 31, 15, 157, 31];
        accept_rel_rf = [0, 80, 112, 15, 157, 31];
        
        // 'Town produced' absolute cargo amounts. To be overridden -- usually zero. 
        prod_rel = [0,0,0,0,0, 0];

        // 'Town produced' relative factor (get from setting) 
        townprod_fct = 650;
        
        // Add 'produced' to 'accepted' requirement
        tpa = [0,1,0,1,0, 0];
        
        
    }
    function computeAcceptReq(population, i, production, townID);
 
    function getPaxCargo();
    function getMailCargo();
}
function econ_desert::getPaxCargo() {return 1;}
function econ_desert::getMailCargo() {return 3;}
 
    // on tropic maps, set water requirement to 0 (zero) in non-desert towns
	// doesn't seem to be working, sets req to 0 always. ?!?
 function econ_desert::computeAcceptReq(population, i, production, townID) { 
    if(GSTile.GetTerrainType(GSTown.GetLocation(townID)) == GSTile.TERRAIN_RAINFOREST){
        if(tpa[i] == 0) {
            return accept_rel_rf[i] * population / 1000;
        } else {
           return accept_rel_rf[i] * population / 1000 + production * townprod_fct / 1000;     
        }
	} else {
        if(tpa[i] == 0) {
            return accept_rel[i] * population / 1000;
        } else {
           return accept_rel[i] * population / 1000 + production * townprod_fct / 1000;     
        }	
	}
}
