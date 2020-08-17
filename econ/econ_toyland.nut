 
 
require("econ.nut");
 class econ_toyland extends econ{
 
 
 
    constructor() {	
	    if(GSController.GetSetting("debug_level") > 1) {
	        GSLog.Info("Loading Toyland economy.");
	    }     
        // Cargo enable order, Needs to be overridden
        num_cargos = 5;
        enable_order = [5, 0, 2, 11, 3];
        enable_populations = [200, 500, 1000, 2000, 3000];
        max_populations = [700, 1500, 2500, 4000, 6000];
        decay_rates = [400, 1000, 1000, 300, 150];
        
        // 'Town accepted' absolute cargo amounts. Needs to be overridden
        accept_rel = [114, 80, 15, 97, 89];
        
        // 'Town produced' absolute cargo amounts. To be overridden -- usually zero. 
        prod_rel = [0,0,0,0,0];

        // 'Town produced' relative factor (get from setting) 
        townprod_fct = 650;
        
        // Add 'produced' to 'accepted' requirement
        tpa = [0,1,1,0,0];
        
        
    }
 
 }
