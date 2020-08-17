
// ECONOMY tpl class. 
// Extended by 'economy' classes that hold information about relative production of cargos accepted by towns
// Under certain economies. 

// 
// 

class econ {

    month_lengths = [31,28,31,30,31, 30,31,31,30,31, 30,31];
    // Total cargo requirement.     
    multiplier_car = 1000;    
    multiplier_pop = 1000;    
    
    // Cargo enable order, Needs to be overridden
    num_cargos = 5;
    enable_order = [1, 0, 2, 5, 10];
    enable_populations = [200, 500, 1000, 2000, 3000];
    max_populations = [700, 1500, 2500, 4000, 6000];
    decay_rates = [50, 1000, 1000, 250, 100];
    
    // 'Town accepted' absolute cargo amounts. Needs to be overridden
    accept_rel = [89,80,15,183,27];
    
    // 'Town produced' absolute cargo amounts. To be overridden -- usually zero. 
    prod_rel = [0,0,0,0,0];

    // 'Town produced' relative factor (get from setting) 
    townprod_fct = 650;
    
    // Add 'produced' to 'accepted' requirement
    tpa = [0,1,1,0,0];
        
    constructor() {	
	    if(GSController.GetSetting("debug_level") > 1) {
	        GSLog.Info("Loading Basic economy.");
	    }
    }
    function init();    
    function deliveryReqs(population, cargo_produced, accept_reqs, prod_reqs, townID);
    function computeAcceptReq(population, i, production, townID);
    function getPaxCargo();
    function getMailCargo();
    function hasAdditionalRequirements();
    function correctZeroes();
}
function econ::getPaxCargo() {return 1;}
function econ::getMailCargo() {return 2;}

function econ::init() {
     this.multiplier_car = GSController.GetSetting("cargomul");
     this.multiplier_pop = GSController.GetSetting("intromul");
     this.townprod_fct = GSController.GetSetting("metro_cgg") * 10;
        for(local i = 0; i < this.num_cargos; ++i) {
            this.enable_populations[i] *= this.multiplier_pop;
            this.enable_populations[i] /= 1000;
            this.max_populations[i] *= this.multiplier_pop;
            this.max_populations[i] /= 1000;            
            
            this.accept_rel[i] *= this.multiplier_car;
            this.accept_rel[i] /= 1000;
            this.prod_rel[i] *= this.multiplier_car;
            this.prod_rel[i] /= 1000;
            
            // Invert each decay rate (faster calculations).
            this.decay_rates[i] = 1000 - this.decay_rates[i];
            
        }   
    }

// Delivery requirements for sustain. 
function econ::deliveryReqs(population, cargo_produced, accept_reqs, prod_reqs, townID) {
    local i = 0;
    while(i < this.num_cargos && population >= enable_populations[i]) {
        if(population < max_populations[i]) {
            local pop_diff = population - enable_populations[i]
            local max_diff = max_populations[i] - enable_populations[i];                        
            prod_reqs[i] = (this.computeProdReq(population, i, cargo_produced[i],townID) * pop_diff / max_diff).tointeger();  
            accept_reqs[i] = (this.computeAcceptReq(population, i, cargo_produced[i],townID) * pop_diff / max_diff).tointeger();       
        } else {                
            prod_reqs[i] = this.computeProdReq(population, i, cargo_produced[i],townID);  
            accept_reqs[i] = this.computeAcceptReq(population, i, cargo_produced[i],townID);
        }
        // Require at least 1 unit of cargo iff population > minimum
        if(prod_reqs[i] == 0 && this.prod_rel[i] > 0) {
            prod_reqs[i] = 1;
        }
        if(accept_reqs[i] == 0 && this.accept_rel[i] > 0) {
            accept_reqs[i] = 1;
        }
        ++i;
    }
    while(i < this.num_cargos) {
        prod_reqs[i] = 0;
        accept_reqs[i] = 0;
        ++i;
    }
}

function econ::computeAcceptReq(population, i, production, townID) {
    if(tpa[i] == 0) {
        return accept_rel[i] * population / 1000;
    } else {
        local m = GSDate.GetMonth(GSDate.GetCurrentDate()) - 1;
       return accept_rel[i] * population / 1000 + production * townprod_fct / 1000 * month_lengths[m] / month_lengths[(m+11)%12];     
    }
}

function econ::hasAdditionalRequirements() {
    return false;    
}

function econ::computeProdReq(population, i, production, townID) {
   return prod_rel[i] * population / 1000 + production * townprod_fct / 1000;    
}

function econ::GetNextDemand(population) {
    local i = 0; 
    while(i < this.num_cargos && population >= enable_populations[i]) {
        ++i;
    }
    return i < this.num_cargos ? i : -1;    
}


function econ::correctZeroes() {
    local tbr = [];
    for(local i = 0; i < num_cargos; ++i) {
        if(prod_rel[i] == 0 && accept_rel[i] == 0 && tpa[i] == 0) {
            tbr.append(i);
        }
    }
    /* TODO: 
    this.num_cargos -= tbr.len();
    REMARRAYBYINDEX(this.enable_order, tbr);
    REMARRAYBYINDEX(this.enable_populations, tbr);
    REMARRAYBYINDEX(this.max_populations, tbr);
    REMARRAYBYINDEX(this.decay_rates, tbr);
    REMARRAYBYINDEX(this.accept_rel, tbr);
    REMARRAYBYINDEX(this.prod_rel, tbr);
    */
}

