
require("econ.nut");
 class econ_firs extends econ{ 
 
    static PLAIN = 1;
    static ARCTIC = 2;
    static TROPIC = 3;
    static STEEL = 4;
    static HOT = 5;
    static EXTREME = 6;
    static ONEFOUR = 7; // Old FIRS v1.4
 
 
    constructor(econ) {	
	    if(GSController.GetSetting("debug_level") > 1) {
	        GSLog.Info("Loading FIRS economy.");
	    }
        switch(econ) {
            case(econ_firs.PLAIN):
                this.init_plain();
                break;
            case(econ_firs.ARCTIC):
                this.init_arctic();
                break;
            case(econ_firs.TROPIC):
                this.init_tropic();
                break;
            case(econ_firs.STEEL):
                this.init_steel();
                break;
            case(econ_firs.HOT):
                this.init_hot();
                break;
            case(econ_firs.EXTREME):
                this.init_extreme();
                break;
            case(econ_firs.ONEFOUR):
                this.init_1_4();
                break;
        }
        // 'Town produced' relative factor (get from setting) 
        townprod_fct = 650;
    }
    
    function init_plain() {
        // Cargo enable order, Needs to be overridden
        num_cargos = 5;
        // Passengers, Food, Mail, Goods, Alcohol
        enable_order = [0, 11, 2, 5, 1];
        enable_populations = [200, 500, 1000, 2500, 4000];
        max_populations = [1000, 1500, 3000, 6000, 10000];
        decay_rates = [1000, 250, 1000, 150, 60];
        // 'Town accepted' absolute cargo amounts. Needs to be overridden
        accept_rel = [90, 113, 15, 72, 15];
        // 'Town produced' absolute cargo amounts. To be overridden -- usually zero. 
        prod_rel = [0,0,0,0,0];
        // Add 'produced' to 'accepted' requirement
        tpa = [1,0,1,0,0];  
    }
    function init_arctic() {
        // Cargo enable order, Needs to be overridden
        num_cargos = 6;
        // Peat, Passengers, Food, Mail, Goods, Alcohol
        enable_order = [18, 0, 11, 2, 5, 8];
        enable_populations = [200, 500, 1000, 1500, 2500, 4000];
        max_populations = [750, 1250, 2000, 3250, 5000, 7500];
        decay_rates = [1000, 1000, 250, 1000, 150, 60];
        // 'Town accepted' absolute cargo amounts. Needs to be overridden
        accept_rel = [43, 90, 73, 15, 60, 24];
        // 'Town produced' absolute cargo amounts. To be overridden -- usually zero. 
        prod_rel = [0,0,0,0,0,0];
        // Add 'produced' to 'accepted' requirement
        tpa = [0,1,0,1,0,0];  
    }
    function init_tropic() {
        // Cargo enable order, Needs to be overridden
        num_cargos = 5;
        // Passengers, Food, Mail, Goods, Alcohol
        enable_order = [0, 11, 2, 5, 1];
        enable_populations = [200, 500, 1000, 2500, 4000];
        max_populations = [1000, 1500, 3000, 6000, 10000];
        decay_rates = [1000, 250, 1000, 150, 60];
        // 'Town accepted' absolute cargo amounts. Needs to be overridden
        accept_rel = [90, 149, 15, 31, 19];
        // 'Town produced' absolute cargo amounts. To be overridden -- usually zero. 
        prod_rel = [0,0,0,0,0];
        // Add 'produced' to 'accepted' requirement
        tpa = [1,0,1,0,0];  
    }
    
    function init_steel() {
        // Cargo enable order, Needs to be overridden
        num_cargos = 4;
        // Passengers, Food, Mail, Vehicles
        enable_order = [0, 11, 2, 5];
        enable_populations = [200, 500, 1000, 2500];
        max_populations = [1000, 1500, 3000, 10000];
        decay_rates = [1000, 250, 1000, 20];
        // 'Town accepted' absolute cargo amounts. Needs to be overridden
        accept_rel = [90, 73, 15, 127];
        // 'Town produced' absolute cargo amounts. To be overridden -- usually zero. 
        prod_rel = [0,0,0,0];
        // Add 'produced' to 'accepted' requirement
        tpa = [1,0,1,0];  
    }
    
    function init_hot() {
        // Cargo enable order, Needs to be overridden
        num_cargos = 7;
        // Build mats, Passengers, Food, Mail, Goods, Alcohol, Petrol
        enable_order = [3, 0, 11, 2, 5, 8, 1, 13];
        enable_populations = [200, 500, 1000, 1500, 2500, 4000, 6000];
        max_populations = [750, 1250, 2000, 3250, 5000, 7500, 11000];
        decay_rates = [50, 1000, 250, 1000, 150, 60, 20];
        // 'Town accepted' absolute cargo amounts. Needs to be overridden
        accept_rel = [78, 90, 70, 15, 15, 33, 4];
        // 'Town produced' absolute cargo amounts. To be overridden -- usually zero. 
        prod_rel = [0,0,0,0,0,0,0];
        // Add 'produced' to 'accepted' requirement
        tpa = [0,1,0,1,0,0,0];  
    }
    
    function init_extreme() {
        // Cargo enable order, Needs to be overridden
        num_cargos = 9;
        // Build mats, Passengers, Food, Mail, Goods, Petrol, Coal, Alcohol, Fruit.
        enable_order = [4, 0, 11, 2, 5, 22, 8, 1, 13];
        enable_populations = [200, 500, 1000, 1500, 2500, 4000, 6000, 9000, 12500];
        max_populations = [750, 1250, 2000, 3250, 5000, 7500, 11000, 15000, 20000];
        decay_rates = [50, 1000, 250, 1000, 150, 20, 20, 60, 350];
        // 'Town accepted' absolute cargo amounts. Needs to be overridden
        accept_rel = [50, 90, 77, 15, 36, 11, 3, 18, 6];
        // 'Town produced' absolute cargo amounts. To be overridden -- usually zero. 
        prod_rel = [0,0,0,0,0,0,0,0,0];
        // Add 'produced' to 'accepted' requirement
        tpa = [0,1,0,1,0,0,0,0,0];  
    }
 
    function init_1_4() {
    
        // Cargo enable order, Needs to be overridden
        num_cargos = 9;
        // Build mats, Passengers, Food, Mail, Goods, Petrol, Coal, Alcohol, Fruit.
        enable_order = [28, 0, 11, 2, 5, 29, 8, 25, 13];
        enable_populations = [200, 500, 1000, 1500, 2500, 4000, 6000, 9000, 12500];
        max_populations = [750, 1250, 2000, 3250, 5000, 7500, 11000, 15000, 20000];
        decay_rates = [50, 1000, 250, 1000, 150, 20, 20, 125, 350];
        
        // 'Town accepted' absolute cargo amounts. Needs to be overridden
        accept_rel = [47, 90, 74, 15, 46, 15, 10, 15, 4];
        
        // 'Town produced' absolute cargo amounts. To be overridden -- usually zero. 
        prod_rel = [0,0,0,0,0,0,0,0];

        // 'Town produced' relative factor (get from setting) 
        townprod_fct = 650;
        
        // Add 'produced' to 'accepted' requirement
        tpa = [0,1,0,1,0,0,0,0]; 
    }
 
 
    function getPaxCargo();
    function getMailCargo();
}
function econ_firs::getPaxCargo() {return 0;}
function econ_firs::getMailCargo() {return 2;}
