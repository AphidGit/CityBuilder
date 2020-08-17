
require("econ.nut");
 class econ_arctic extends econ{
 
 
 
    constructor() {	   
	    if(GSController.GetSetting("debug_level") > 1) {
	        GSLog.Info("Loading Arctic economy.");
	    }     
        // Cargo enable order, Needs to be overridden
        num_cargos = 6;
        enable_order = [1, 0, 11, 2, 5, 10];
        enable_populations = [200, 500, 1000, 2000, 3000, 5000];
        max_populations = [700, 1500, 2500, 4000, 6000, 7500];
        decay_rates = [50, 1000, 175, 1000, 100, 20];
        
        // 'Town accepted' absolute cargo amounts. Needs to be overridden
        accept_rel = [109, 80, 99, 15, 72, 20];
        
        // 'Town produced' absolute cargo amounts. To be overridden -- usually zero. 
        prod_rel = [0,0,0,0,0, 0];
        
        // Add 'produced' to 'accepted' requirement
        tpa = [0,1,0,1,0, 0];
        
        
    }
 
    function getPaxCargo();
    function getMailCargo();
}
function econ_arctic::getPaxCargo() {return 1;}
function econ_arctic::getMailCargo() {return 3;}
