// ----------------------------------------------------------------------------
// AKS Real Estate Smart Contract
//
// A gas-efficient Solidity Smart Contract
//
// 24th September 2020
//
// GNU Lesser General Public License 3.0
// https://www.gnu.org/licenses/lgpl-3.0.en.html
// ----------------------------------------------------------------------------

pragma solidity>=0.4.22 <0.7.0;
import "BokkyPooBahsDateTimeLibrary.sol";

contract RealEstateRentContract {

    address payable owner;
    address payable tenant;
    address payable broker1;
    address payable broker2;
    address payable broker3;
    address witness1;
    address witness2;
    address payable maintenance_account;
    address payable electricity_account;
    address payable water_charges_account;
    mapping (string=>string) expenses;
    mapping (string=>string) activities;
    mapping (string=>string) houseType;
    mapping (string=>string) damages;
    mapping (string=>uint) damageAmount;

    struct house {
        string society_or_building_name;
        uint house_no;
        string addr;
        uint area;
        uint floor_no;
        bool furnished;
        mapping (string=>uint) fixtures;
        mapping (string=>uint) furnitures;
        bool freshly_painted;
        string[] known_issues;
        string house_type;
    }
    house home;
    uint rent;
    uint brokerage; // Number of days amount equivalent to which is required as brokerage
    uint[] brokerage_split; // How to split brokerage between owner and tenant
    uint[] brokerage_dist; // Percentage distribution of brokerage between brokers
    bool advance; // Advance rent?
    uint payment_window; // For rent payment begining of each month
    uint non_payment_window; // For eviction notice
    uint cancellation_window; // For cancelling Rent Agreement
    uint256 agreement_date; // Unix timestamp
    bool autoRenew; // For auto renewing Rent agreement
    uint256 renewal_date;
    uint cancellation_percentage; // percentage amount to be deducted from security deposit
    // in case of cancellation within the window
    // In case the tenant cancel the agreement out the specfified window,
    // he is liable to pay one month rent
    mapping (uint=>uint256) monthtime;
    uint vacating_notice; // number of days of advance notice required for vacating
    uint256 date_of_vacating; 
    uint totalDamageAmount;
    uint256 rent_start_date; // ,,
    uint maintenance;
    bool fixed_electricity;
    uint electricity_charges;
    uint electricity_per_unit;
    uint water_charges;
    uint security_deposit;
    uint yearly_increment_percentage;
    uint agreement_duration;
    uint group_size;

    constructor() public {
        houseType["apartment"] = "apartment";
        houseType["duplex"] = "duplex";
        houseType["villa"] = "villa";
        houseType["indpendent house"] = "independent house";
        houseType["flat_in_independent_house"] = "flat_in_independent_house";
        monthtime[1] = rent_start_date;
        monthtime[2] = BokkyPooBahsDateTimeLibrary.addMonths(rent_start_date, 1);
        monthtime[3] = BokkyPooBahsDateTimeLibrary.addMonths(rent_start_date, 2);
        monthtime[4] = BokkyPooBahsDateTimeLibrary.addMonths(rent_start_date, 3);
        monthtime[5] = BokkyPooBahsDateTimeLibrary.addMonths(rent_start_date, 4);
        monthtime[6] = BokkyPooBahsDateTimeLibrary.addMonths(rent_start_date, 5);
        monthtime[7] = BokkyPooBahsDateTimeLibrary.addMonths(rent_start_date, 6);
        monthtime[8] = BokkyPooBahsDateTimeLibrary.addMonths(rent_start_date, 7);
        monthtime[9] = BokkyPooBahsDateTimeLibrary.addMonths(rent_start_date, 8);
        monthtime[10] = BokkyPooBahsDateTimeLibrary.addMonths(rent_start_date, 9);
        monthtime[11] = BokkyPooBahsDateTimeLibrary.addMonths(rent_start_date, 10);

    }
    function getMonthTime(uint month) public view returns (uint256) {
        return monthtime[month];
    }

    function setOwner(address payable addr) public  { owner = addr; }
    function setTenant(address payable addr) public { tenant = addr; }
    function setBroker1(address payable addr) public { broker1 = addr; }
    function setBroker2(address payable addr) public { broker2 = addr; }
    function setBroker3(address payable addr) public { broker3 = addr; }
    function setWitness1(address payable addr) public { witness1 = addr; }
    function setWitness2(address payable addr) public { witness2 = addr; }
    function setMaintenanceAccount(address payable addr) public { maintenance_account = addr; }
    function setElecticityChargesAccount(address payable addr) public { electricity_account = addr; }
    function setWaterChargesAccount(address payable addr) public { water_charges_account = addr; }

    function setExpenses() public {
        expenses["structural"] = "owner";
        expenses["fixtures"] = "shared";
        expenses["personal"] = "tenant";
    }

    function setActivities() public {
        activities["maintenance_fees"] = "tenant";
        activities["water_charges"] = "tenant";
        activities["society_specfic"] = "owner";
        activities["agreement"] = "broker";
        activities["inspection"] = "broker";
        activities["handover"] = "broker";
    }

    function setSocietyOrBuildingName(string memory name) public  {
        home.society_or_building_name = name;
    }

    function setHouseNo(uint houseNo) public {
        home.house_no = houseNo;
    }

    function setHouseAddr(string memory addr) public {
        home.addr = addr;
    }

    function setHouseArea(uint area) public {
        home.area = area;
    }

    function setFloorNo(uint floor) public {
        home.floor_no = floor;
    }

    function setFurnish(bool furnish) public {
        home.furnished = furnish;
    }

    function setFixture(string memory item, uint num) public {
        home.fixtures[item] = num;
    }

    function setFurniture(string memory item, uint num) public {
        home.furnitures[item] = num;
    }

    function setFreshlyPainted(bool painted) public {
        home.freshly_painted = painted;
    }

    function setKnownIssue(string memory issue) public {
        home.known_issues.push(issue);
    }

    function setHouseType(string memory t) public {
        home.house_type =  houseType[t];
    }

    function setRent(uint val) public {
        rent = val;
    }

    function setBrokerage(uint daysno) public {
        brokerage = daysno;
    }
    function setBrokerageSplit(uint ownerShare, uint tenantShare) public {
        brokerage_split.push(ownerShare);
        brokerage_split.push(tenantShare);
    }

    function setBrokerageDistribution(uint broker1Share, uint broker2Share, uint broker3Share) public {
        brokerage_dist.push(broker1Share);
        brokerage_dist.push(broker2Share);
        brokerage_dist.push(broker3Share);
    }
    function setAdvanceRent(bool val) public {
        advance = val;
    }

    function setPaymentWindow(uint window) public {
        payment_window = window;
    }

    function setNonPaymentWindow(uint window) public {
        non_payment_window = window;
    }

    function setCancellationWindow(uint window) public {
        cancellation_window = window;
    }

    function setAgreementDate(uint256 date) public {
        agreement_date = date;
    }

    function setRentStartDate(uint256 date) public {
        rent_start_date = date;
    }

    function setAutoRenew(bool renew) public {
        autoRenew = renew;
    }

    function setRenewalDate(uint months) public {
        renewal_date = BokkyPooBahsDateTimeLibrary.addMonths(rent_start_date, months);
    }

    function setCancellationPercentage(uint percentage) public {
        cancellation_percentage = percentage;
    }


    function setVacatingNotice(uint daysno) public {
        vacating_notice = daysno;
    }

    function setDateOfVacating(uint256 date) public  {
        date_of_vacating = date;
    }

    function setMaintenance(uint amount) public {
        maintenance = amount;
    }

    function setFixedElectricity(bool val) public {
        fixed_electricity = val;
    }

    function setElectrictyCharges(uint charge) public {
        if (fixed_electricity) {
            electricity_charges = charge;
        } else {
            electricity_charges = 0;
        }
    }

    function setElectricityPerUnit(uint unit) public {
        electricity_per_unit = unit;
    }

    function setMonthlyWaterCharges(uint charge) public {
        water_charges = charge;
    }

    function setSecurityDeposit(uint amount) public {
        security_deposit = amount;
    }

    function setYearlyIncrementPercentage(uint percent) public {
        yearly_increment_percentage = percent;
    }

    function setAgreementDuration(uint months) public {
        agreement_duration = months;
    }

    function setNumberOfResidents(uint num) public {
        group_size = num;
    }

    function updateDamages(string memory item, string memory status, uint amount) public {
        damages[item] = status;
        damageAmount[item] = amount;
        totalDamageAmount += amount;
    }

    // Operations
    //
    //
    // Deposit Security
    event SecurityDeposited(address to, address from, uint amount);
    function depositSecurity() public payable {
        require(tenant.balance >= security_deposit);
        tenant.transfer(security_deposit);
        owner.transfer(address(this).balance);
        emit SecurityDeposited(owner, tenant, security_deposit);
    }

    // Pay Tenant Brokerage
    event PayTenantBrokerage(address to1, address to2, address to3, address from, uint amount);
    function payTenantBrokerage() public payable {
        uint tenantBrokerageAmount = (brokerage/30)*rent/2;
        require(tenant.balance >= tenantBrokerageAmount);
        tenant.transfer(tenantBrokerageAmount);
        broker1.transfer(address(this).balance*brokerage_dist[0]/100);
        broker2.transfer(address(this).balance*brokerage_dist[1]/100);
        broker3.transfer(address(this).balance*brokerage_dist[2]/100);
        emit PayTenantBrokerage(broker1, broker2, broker3, tenant, tenantBrokerageAmount);
    }

    // Pay Owner Brokerage
    event PayOwnerBrokerage(address to1, address to2, address to3, address from, uint amount);
    function payOwnerBrokerage() public payable {
        uint ownerBrokerageAmount = (brokerage/30)*rent/2;
        require(owner.balance >= ownerBrokerageAmount);
        tenant.transfer(ownerBrokerageAmount);
        broker1.transfer(address(this).balance*brokerage_dist[0]/100);
        broker2.transfer(address(this).balance*brokerage_dist[1]/100);
        broker3.transfer(address(this).balance*brokerage_dist[2]/100);
        emit PayOwnerBrokerage(broker1, broker2, broker3, owner, ownerBrokerageAmount);
    }

    // Cancel Agreement
    event CancelAgreement(address party1, address party2, address party3, address party4, address party5); 
    function cancelAgreement() public payable {
        //Check for valid window
        owner.transfer(security_deposit);
        tenant.transfer(address(this).balance);
        broker1.transfer((brokerage/30)*rent*brokerage_dist[0]/100);
        broker2.transfer((brokerage/30)*rent*brokerage_dist[1]/100);
        broker3.transfer((brokerage/30)*rent*brokerage_dist[2]/100);
        tenant.transfer(address(this).balance/2);
        owner.transfer(address(this).balance/2);
        emit CancelAgreement(owner, tenant, broker1, broker2, broker3);
    } 

    // Notify for vacating by owner to tenant
    event TenantNotifiedToVacate(address to, uint amount);
    function notifyForVacating() public payable{
        // todo: allowed window calculation
        uint amountPending = rent + maintenance + water_charges + electricity_charges;
        if (tenant.balance < amountPending) {
            emit TenantNotifiedToVacate(tenant, amountPending);
        }
    }

    // Deduct from security
    event DeductFromSecurity(address to, address from);
    function deductFromSecurity() public payable {
        uint amountPending = rent + maintenance + water_charges + electricity_charges;
        security_deposit -= amountPending;
        emit DeductFromSecurity(owner, tenant);
    }

    // Refund Security
    event RefundSecurity(address to, address from);
    function refundSecurity() public payable {
        require(owner.balance >= security_deposit);
        owner.transfer(security_deposit);
        tenant.transfer(address(this).balance);
        emit RefundSecurity(tenant, owner);
    }
    // Renew Agreement
    event RenewAgreement(address to, address from);
    function renewAgreement() public payable {
        require (now > BokkyPooBahsDateTimeLibrary.addMonths(agreement_date, 1));
        agreement_date = now;
        rent = rent + rent*(yearly_increment_percentage/100);
        emit RenewAgreement(tenant, owner);
    }


    // Deduct damages
    event DeductDamages(address to, address from, uint amount);
    function deductDamages() public payable {
        require (now > BokkyPooBahsDateTimeLibrary.addMonths(agreement_date, 11));
        require(tenant.balance >= totalDamageAmount);
        tenant.transfer(totalDamageAmount);
        owner.transfer(address(this).balance);
        emit DeductDamages(owner, tenant, totalDamageAmount);
    }

    // Report non-payment

    event NonPayment(address to, address from, uint amount);
    function notifyForNonPayment() public payable {
        // todo: allowed window calculation
        uint i;
        for (i=0;i<=11;i++) {
            if (monthtime[i] > now) {
                break;
            }
        }
        require (now > BokkyPooBahsDateTimeLibrary.addDays(BokkyPooBahsDateTimeLibrary.addMonths(agreement_date, i), payment_window));
        uint amountPending = rent + maintenance + water_charges + electricity_charges;
        if (tenant.balance < amountPending) {
            emit NonPayment(owner, tenant, amountPending);
        }
    }
    // Notify to vacate by tenant to owner
    event OwnerNotifedOfVacating(address to);
    function notifyToVacate() public payable {
        emit OwnerNotifedOfVacating(owner);
    }

    // Pay Rent
    event PayRent(address to, address from, uint amount);
    function payRent() public payable {
        tenant.transfer(rent);
        owner.transfer(address(this).balance);
        emit PayRent(owner, tenant, rent);
    }

    // Pay Maintenance
    event PayMaintenance(address to, address from, uint amount );
    function payMaintenance() public payable {
        require(tenant.balance >= maintenance);
        tenant.transfer(maintenance);
        maintenance_account.transfer(address(this).balance);
        emit PayMaintenance(maintenance_account, tenant, maintenance);
    }

    // Pay Electricity
    event PayElectricityCharges(address to, address from, uint amount );
    function payElectricityCharges() public payable {
        require(tenant.balance >= electricity_charges);
        tenant.transfer(electricity_charges);
        electricity_account.transfer(address(this).balance);
        emit PayElectricityCharges(electricity_account, tenant, electricity_charges);
    }

    // Pay Water Charges
    event PayWaterCharges(address to, address from, uint amount);
    function payWater() public payable {
        require(tenant.balance >= water_charges);
        tenant.transfer(water_charges);
        water_charges_account.transfer(address(this).balance);
        emit PayWaterCharges(water_charges_account, tenant, water_charges);
    }
}

contract NewAgreement is RealEstateRentContract {

    function setData() public {
        setExpenses();
        setActivities();
        setSocietyOrBuildingName("Hyde Park");
        setHouseNo(906);
        setHouseAddr("Sector 20, Noida, UP-201301");
        setHouseArea(1370);
        setFloorNo(9);
        setFurnish(false);
        setFixture("Fan", 5);
        setFixture("Tubelight", 8);
        setFixture("Kitchen Chimney", 1);
        setFixture("Water heater", 2);
        setFixture("Water RO", 1);
        setFreshlyPainted(true);
        setKnownIssue("Seepage in Kitchen");
        setHouseType("apartment");
        setRent(15);
        setBrokerage(8);
        setBrokerageSplit(50,50);
        setBrokerageDistribution(50,40,10);
        setAdvanceRent(true);
        setPaymentWindow(5);
        setNonPaymentWindow(30);
        setCancellationWindow(10);
        setAgreementDate(1600603200);
        setRentStartDate(1601510400);
        setAutoRenew(true);
        setRenewalDate(11);
        setCancellationPercentage(5);
        setVacatingNotice(30);
        setMaintenance(3);
        setFixedElectricity(true);
        setElectrictyCharges(2);
        setElectricityPerUnit(6);
        setMonthlyWaterCharges(1);
        setSecurityDeposit(20);
        setYearlyIncrementPercentage(5);
        setAgreementDuration(11);
        setNumberOfResidents(4);
    }
    function setup() public payable {
        depositSecurity();
        payTenantBrokerage();
        payOwnerBrokerage();
    }
    function execute() public payable {
        for (uint month = 1; month <=11; month++) {
            require ((now - getMonthTime(month)) < 1 days);
            payRent();
            payMaintenance();
            payElectricityCharges();
            payTenantBrokerage();
        }
    }
    function cancel() public payable {
        cancelAgreement();
    }
    function renew() public {
        renewAgreement();
    }
    function selfVacate() public payable {
        deductDamages();
        // Event Handling Required
        notifyForVacating();
        deductFromSecurity();
    }

    function forceVacate() public payable {
        deductDamages();
        // Event Handling Required
        notifyToVacate();
        deductFromSecurity();
    }
}