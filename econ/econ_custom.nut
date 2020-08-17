
require("../QSort.nut");
require("econ.nut");
 class econ_custom extends econ{
    constructor() {	        
        // Cargo enable order, Needs to be overridden
        num_cargos = 0;        
        loadCargoes();       
    }
    function loadCargoes();
    function getPaxCargo();
    function getMailCargo();
}
function econ_custom::getPaxCargo() {return 1;}
function econ_custom::getMailCargo() {return 3;}
function econ_custom::loadCargoes() {
    local enable_order_presort = [];
    local enable_population_presort = [];
    local max_population_presort = [];
    local decay_rate_presort = [];
    local accept_rel_presort = [];
    local prod_rel_presort = [];
    local tpa_presort = [];
    
    for(local i = 0; i < 32; ++i) {
        local dlv = GSController.GetSetting("cargo_dlv["+i+"]");
        local sup = GSController.GetSetting("cargo_sup["+i+"]");
        if(dlv > 0 || sup > 0) {
            local dcr = GSController.GetSetting("cargo_dcr["+i+"]");
            local intr = GSController.GetSetting("cargo_int["+i+"]");
            local max = GSController.GetSetting("cargo_max["+i+"]");        
            accept_rel_presort.push(dlv);
            prod_rel_presort.push(sup);
            enable_order_presort.push(i);
            enable_population_presort.push(intr);
            max_population_presort.push(max);
            decay_rate_presort.push(dcr);      
            tpa_presort.push(0);
        }         
    }
    
    if(enable_order_presort.len() > 0) {
        // Sort the stuff
        this.enable_order = QSort(enable_population_presort, enable_order_presort);
        this.enable_populations = QSort(enable_population_presort, enable_population_presort);
        this.max_populations = QSort(enable_population_presort, max_population_presort);
        this.decay_rates = QSort(enable_population_presort, decay_rate_presort);
        this.accept_rel = QSort(enable_population_presort, accept_rel_presort);
        this.prod_rel = QSort(enable_population_presort, prod_rel_presort);
        this.tpa = QSort(tpa_presort, tpa_presort);
        this.num_cargos = enable_order_presort.len();
    } else {
        GSLog.Info("Custom economy specified, but no requirements found. ", Log.LVL_WARNING)
        this.enable_order = [];
        this.enable_populations = [];
        this.max_populations = [];
        this.decay_rates = [];
        this.accept_rel = [];
        this.prod_rel = [];
        this.tpa = [];
    }
    
}
