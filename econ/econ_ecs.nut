
require("econ.nut");
 class econ_ecs extends econ{
 
    vectors = {};
    factprod = 0;
 
    constructor() {	
	    if(GSController.GetSetting("debug_level") > 1) {
	        GSLog.Info("Loading ECS economy.");
	    }     
        this.getVectors();
                
        const PASS = 0;
        const MAIL = 2;
        const GOODS = 5;
        const GOLD = 10;
        const FOOD = 11;
        
        const CARS = 24;
        const PETROL = 25;
        
        const BRICKS = 26;
        const WATER = 27;
        const CEMENT = 28;
        const TOUR = 31;
        
        const eBRICKS = 0;
        const eWATER = 1;
        const eFOOD = 2;
        const ePASS = 3;
        const eMAIL = 4;
        const eGOODS = 5;
        const eCEMENT = 6;
        const ePETROL = 7;
        const eCARS = 8;
        const eGOLD = 9;
        const eTOUR = 10;
        
        // Cargo enable order, Needs to be overridden
        num_cargos = 11;
        enable_order = [BRICKS, WATER, FOOD, PASS, MAIL, GOODS, CEMENT, PETROL, CARS ,GOLD, TOUR];
        enable_populations = [200, 400, 650, 1000, 1500, 2250, 3500, 5000, 7000, 10000, 15000];
        max_populations = [500, 800, 1250, 1900, 2750, 4250, 6000, 8500, 12000, 17500, 25000];
        decay_rates = [50, 150, 175, 1000, 1000, 100, 50, 75, 50, 20, 1000];
        
        // 'Town accepted' absolute cargo amounts. Needs to be overridden
        accept_rel = [0,0,0,80,15, 0,0,0,0,0, 0];
        
        // 'Town produced' absolute cargo amounts. To be overridden -- usually zero. 
        prod_rel = [0,0,0,0,0, 0,0,0,0,0, 0];
        
        // Add 'produced' to 'accepted' requirement
        tpa = [0,0,0,1,1, 0,0,0,0,0, 1];
        
        // Add any enabled 'vectors' to the cargo requirements
        this.addVectors();
        // Remove any cargoes from the requirements that still have a 'zero' accepted requirement. 
        this.correctZeroes();
        
        for(local i = 0; i < num_cargos; ++i) {
            GSLog.Info("CARGO: " + GSCargo.GetCargoLabel(enable_order[i]) + " : REQ : " + accept_rel[i] );
        }        
        // FACTORY production level -- determines dyes used by factory. 
        factprod = 0;  
    }
    function addVectors();
    function getVectors();
    function getPaxCargo();
    function getMailCargo();
    
    function addAgiculturalVector();
    function addConstructionVector();
    function addExtraVector();
    function addMachineryVector();
    function addTownVector();
    function addWoodVector();
    
};
function econ_ecs::getPaxCargo() {return 0;}
function econ_ecs::getMailCargo() {return 2;}
function econ_ecs::getVectors() {
    // Detect the WOOD vector with the WOOD cargo
    if(GSCargo.GetCargoLabel(7) == "WOOD") {
        this.vectors.wood <- true;
         GSLog.Info("WOOD VECTOR: YES");
    } else {
        this.vectors.wood <- false;
         GSLog.Info("WOOD VECTOR: NO");
    }
    // Detect the CHEMICAL vector with the OIL cargo
    if(GSCargo.GetCargoLabel(3) == "OIL_") {
        this.vectors.chemical <- true;
         GSLog.Info("CHEMICAL VECTOR: YES");
    } else {
        this.vectors.chemical <- false;
         GSLog.Info("CHEMICAL VECTOR: NO");
    }   
    // Detect the MACHINERY vector with the VEHICLES cargo
    // With this vector 'vehicles' are produced which increase production. 
    if(GSCargo.GetCargoLabel(24) == "VEHI") {
        this.vectors.machinery <- true;
         GSLog.Info("MACHINERY VECTOR: YES");
    } else {
        this.vectors.machinery <- false;
         GSLog.Info("MACHINERY VECTOR: NO");
    }   
    // Detect the AGICULTURAL vector with the FIBRE cargo
    if(GSCargo.GetCargoLabel(29) == "FICR") {
        this.vectors.agicultural <- true;
         GSLog.Info("AGI VECTOR: YES");
    } else {
        this.vectors.agicultural <- false;
         GSLog.Info("AGI VECTOR: NO");
    }
    // Detect the BASE II vector with the GLASS cargo    
    if(GSCargo.GetCargoLabel(18) == "GLAS") {
        this.vectors.ex <- true;
         GSLog.Info("BASE2 VECTOR: YES");
    } else {
        this.vectors.ex <- false;
         GSLog.Info("BASE2 VECTOR: NO");
    }     
    // Detect the CONSTRUCTION vector with the BRICKS cargo
    if(GSCargo.GetCargoLabel(26) == "BRCK") {
        this.vectors.construction <- true;
         GSLog.Info("CONSTR VECTOR: YES");
    } else {
        this.vectors.construction <- false;
         GSLog.Info("CONSTR VECTOR: NO");
    }   
}

function econ_ecs::addVectors() {
    // Always add the town vector as it's the 'base' vector. 
    local glass = 0;
    this.addTownVector();
    if(this.vectors.ex) {
        glass = this.addExtraVector();
    }
    if(this.vectors.construction) {
        this.addConstructionVector();
    }
    if(this.vectors.wood) {
        this.addWoodVector();
    }
    if(this.vectors.machinery) {
        this.addMachineryVector();
    }
    if(this.vectors.agicultural) {
        this.addAgiculturalVector(glass);
    }
    if(this.vectors.chemical) {
        this.addChemicalVector();
    }
    // Halve all non-pax requirements -- otherwise total ends up being too high 
    // compared to other sets. 
    for(local i = 0; i < this.num_cargos; ++i) {
        if(this.tpa[i] == 0) {
            this.accept_rel[i] /= 2;
        }
    }
}

function econ_ecs::addTownVector() {
    // GOLD: 1 per 37.5K 
    // Gold mine production ~ 600 w/o machinery vector
    // 750 with machinery vector. 
    // Result --> 8-10
    if(this.vectors.machinery) {
        this.accept_rel[eGOLD] += 20;
    } else {
        this.accept_rel[eGOLD] += 16;
    }
    // WATER: 1 per 25K
    // WATER production: ~2750
    // Result --> 110
    this.accept_rel[eWATER] += 110;
    
    if(!this.vectors.machinery && !this.vectors.ex) {
        // Goods are produced by factory by default. 
        // STD production: 1500. 
        // Result --> 60
        this.accept_rel[eGOODS] += 60;        
    } else {
        // If we have machinery or base II vector
        // Don't add anything 
        // factory only 'processes' stuff from other vectors. 
    }
}

function econ_ecs::addExtraVector() {
    // COAL --> 
    // amount ~ 1 per 10K
    // SAND -->
    // Amount: 1 per 25K
    // Production: 3600 (machinery) - 2800 (no)
    local coal = 0, sand = 0, glass = 0;
    if(this.vectors.machinery) {
        coal = 200;
        sand = 144;
    } else {
        coal = 120;
        sand = 112;
    } 
    // If we have MACHINERY vector --> some coal is used for steel
    if(this.vectors.machinery) {
        coal -= 56;
    }    
    // If we have CONSTRUCTION vector --> some sand used for concrete,  
    if(this.vectors.construction)  {
        if(this.vectors.machinery) {
            sand -= 96;
        } else {
            sand -= 48;
        }
    }    
    // With what's left of sand: make glass. 
    if(sand / 2 > coal) {
        glass = coal;
    } else {
        glass = sand / 2;
    }
    coal -= glass;
    glass *= 5;
    // Glass for vehicles
    if(this.vectors.machinery) {
        glass -= 6;
    }    
    // glass for furniture
    if(this.vectors["wood"]) {
        if(this.vectors.machinery) {
            glass -= 30;
        } else {
            glass -= 15;
        }        
    }    
    if(!this.vectors.agicultural) {   
        // The rest of the glass is used to make goods @ factory.
        if(glass > 0) { 
            this.accept_rel[eGOODS] += glass / 3;   
            this.factprod += glass / 3;    
        }
    }
    
    // Rest of coal: add to 1st requirement if we have construction 
    if(this.vectors.construction)  {
        if(coal > 0) {
            // 2 coal -> 3 bricks
            this.accept_rel[eBRICKS] += coal * 3 / 2;
        }
    }
    return glass;
}

function econ_ecs::addConstructionVector() {
    local lime = 0, cement = 0, bricks = 0;
    // Construction vector produces 'LIMESTONE'
    // Amount ~ 1 per 25K. 
    // Production: base ~600
    lime = 48;
    // With machinery, production quadruples
    // Without, base production is doubled. 
    if(this.vectors.machinery) {
        lime *= 2;
    }
    // This is used to make CEMENT 1:1    
    // If we also have SAND it's improved
    if(this.vectors.ex) {
        cement = lime;
    } else {
        cement = 2 * lime;
    }
    this.accept_rel[eCEMENT] += cement;
    // BRICKS basis:
    // Amount: ~1 per 50K
    if(this.vectors.ex) {
        // if we have coal, less bricks are produced naturally
        bricks = 6;
    } else {    
        bricks = 60;
    } 
    this.accept_rel[eBRICKS] += bricks;    
}

function econ_ecs::addMachineryVector() {
    local steel = 0;
    // iron = 72 (base ~1800)
    // Steel = iron / 6 * 5; 
    steel = 60;    
    // 12 steel, 4 dyes, 3 glass -> 5 vehicles       
    // ~ 7 types of mines use ~3 vehicles
    // Town uses another 7
    this.accept_rel[eCARS] += 7; 
    steel -= 24;     
    // Use a bit of steel for the 'tinning' if we have agicultural
    if(this.vectors.agicultural) {
        steel -= 3;  
    }    
    // rest of steel goes to GOODS ~ 1:1 via factory 
     this.accept_rel[eGOODS] += steel;  
     this.factprod += steel;  
}

function econ_ecs::addChemicalVector() {
    // OIL base: 1 per 25K producing ~2500
    local oil = 100, rfpr = 0, gasolin = 0;
    // first, assume any oil is made into rfpr. 
    // We can transform back into gasoline later. 
    
    // Factory requirement
    rfpr = this.factprod / 3 * 2;
    // Paper requirement
    // Printing works requirement
    // Only relevant if 'glass' is turned on 
    // else it's better to just use furniture (see wood vector)
    if(this.vectors.wood && this.vectors.ex) {
        if(this.vectors["machinery"]) {
            rfpr += 4; // paper
            rfpr += 4; // printing  
        } else {
            rfpr += 2; // paper  
            rfpr += 2; // printing     
        }
    }
    // Dyes requirement (1:1 from RFPR)
    if(this.vectors.machinery) {
        // 8 dyes for vehicles. 
        rfpr += 8;
    }       
    // Textile mill requirement
    if(this.vectors.agicultural) {
        rfpr += 31;   
    }
    
    oil -= (rfpr * 20) / 17;
    if(oil > 0) {
        gasolin = oil * 9 / 10;
        this.accept_rel[ePETROL] += gasolin;   
    }
}

function econ_ecs::addWoodVector() {
    local wdpr = 0, paper = 0, goods = 0;
    // WOOD vector. 
    // WOOD base: 1 per 20K
    // Prod: 1000 (no mach) / 2000 (mach)
    // Sawmill produces 3/4  
    if(this.vectors.machinery) {
        wdpr = 80;        
    } else {
        wdpr = 40;        
    }    
    // Split between PAPER route and FURNITURE route. 
    // the split depends on which other vectors are available.
    goods = 0;
    if(this.vectors.chemical) {    
        if(this.vectors.ex) {
            // If we have glass::8WP -> 17GOODS
            goods += (wdpr * 17 ) / 16;
            paper = (wdpr * 3) / 8;
            // 8 paper -> 15 goods
            goods += paper * 15 / 8;   
        } else {
            // Best to make only furniture. 
            // Since no glass used. 
            goods += (wdpr * 7 ) / 5;   
        }
    } else {
        // Since ''   
        if(this.vectors.ex) {
            // If we have glass::8WP -> 17GOODS
            goods += (wdpr * 17 ) / 16;
            paper = (wdpr * 3) / 8;
            // 8 paper -> 15 goods
            goods += paper * 15 / 8;   
        } else {
            // best to make only paper
            // Since paper w/o vector produces more than glass. 
            paper = (wdpr * 3) / 4;
            goods += paper * 15 / 8; 
        }        
    }    
    this.accept_rel[eGOODS] += goods; 
}

function econ_ecs::addAgiculturalVector(glass) {
    local fod = 0;
    local goods = 0;
    local petrol = 0;
    
    local cereal = 0, fibre = 0, fruit = 0, olsd = 0, fish = 0, lvst = 0, wool = 0;
    
    // CEREAL base: 1 per 12.5K
    // FIBER base: 1 per 12.5K
    cereal = 109;
    fibre = 163;
    
    // FRUIT base: 1 per 25K
    // OLSD base: 1 per 25K
    // PROD: 1500fruit/300olsd
    fruit = 60;
    olsd = 12;
    
    // FISH base: 1 per 25K
    // Prod ~ 2K
    fish = 80;
        
    // ANIMFARM base: 1 per 50K
    // subtract CEREAL/FIBR/FISH
    // add LIVESTOCK/WOOL
    lvst = 25;
    wool = 50;
    // Animals consume stuff. 
    fish -= 15;
    cereal -= 13;
    fibre -= 11;    
    
    if(this.vectors.ex) {
    // Use 'BREWERY'; use up the glass. 
    // 11 glass + 10 cereal -> 8 food
    // 13 glass + 11 fruit -> 10 food
        local glass_req = (fruit * 13 / 11 + cereal * 11 / 10) / 2;
        if(glass > glass_req) {
            // brew everything
            glass -= glass_req;               
            fod += fruit * 10 / 22;
            fod += cereal * 8 / 20;
            this.accept_rel[eGOODS] += glass / 3; 
            this.factprod += glass / 3;    
            // The remaining half goes via food plant
        } else {
            // brew our remaining glass. 
            local fruit_old = fruit;
            local cereal_old = cereal;
            fruit = fruit * (glass_req - glass) / glass_req / 2 + fruit / 2;
            cereal = cereal * (glass_req - glass) / glass_req / 2 + cereal / 2;
            local fruit_used = fruit_old - fruit;
            local cereal_used = cereal_old - cereal;
            fod += fruit_used * 10 / 11;
            fod += cereal_used * 8 / 10;
        }
        // food-plant the remaining fruit, cereal
        fod += fruit * 3 / 4;
        fod += cereal * 3 / 5;
    } else {
        // since brewery is strictly better than food plant in this case
        // use brewery for all the stuff
        fod += fruit * 10 / 11;
        fod += cereal * 8 / 10;
    }    
    // OIL SEEDS; check if we have CHEMICAL
    if(this.vectors["chemical"]) {
        // CONVERT half of OLSD to GASOLINE via REFINERY; 95% effective
        local oil = olsd * 19 / 40;
        petrol += oil * 9 / 10;  
        // rest gets FOODPLANTed
        fod += olsd * 4 / 10;      
    } else {
        // all the OLSD goes to the FOODPLANT
        fod += olsd * 4 / 5;      
    }
    // CONVERT remaining FIBER and WOOL to GOODS via TEXTILE MILL
    // uses ~ 1 dye. 
    goods += wool * 2255 / 4747;
    // uses ~ 30 dye.
    goods += fibre * 3608 / 2122;    
    // CONVERT remaining LIVESTOCK and FISH to FOOD via TINNING
    if(this.vectors.machinery) {
        // 2482 fish & 53 steel -> 1365 food
        fod += fish * 1365 / 2482;
        // 2958 livestock & 53 steel -> 1664 food
        fod += lvst * 1664 / 2958;
    } else {
        // 3490 fish -> 1082 food
        fod += fish * 1082 / 3490;
        // 3244 livestock -> 1314 food
        fod += lvst * 1314 / 3244;
    }
    // For fertiliser -- we assume things are fine; both brewery and foodplant produce fertiliser along with food. 
    // ADD FOOD, GOODS, GASOLINE requirements to town.
     this.accept_rel[ePETROL] += petrol;  
     this.accept_rel[eGOODS] += goods;  
     this.accept_rel[eFOOD] += fod;      
}




