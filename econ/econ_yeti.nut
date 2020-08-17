 
 
require("econ.nut");
 class econ_yeti extends econ{ 
    constructor() {	
        // Cargo enable order, Needs to be overridden
        num_cargos = 5;
        enable_order = [16, 0, 2, 8, 4];
        enable_populations = [200, 500, 1000, 2000, 4000];
        max_populations = [6000, 1500, 2500, 4000, 6000];
        decay_rates = [1000, 1000, 1000, 200, 40];
        
        // 'Town accepted' absolute cargo amounts. Needs to be overridden
        accept_rel = [0, 80, 15, 200, 10];
        
        // 'Town produced' absolute cargo amounts. To be overridden -- usually zero. 
        prod_rel = [250,0,0,0,0];

        // 'Town produced' relative factor (get from setting) 
        townprod_fct = 650;
        
        // Add 'produced' to 'accepted' requirement
        tpa = [0,1,1,0,0];        
    }
 
 }
