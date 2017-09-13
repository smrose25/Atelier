/// An order for currency.
Class FCE.CurrencyOrder Extends (%Persistent, %Populate, %XML.Adaptor)
{

/// name of requestor
Property Requestor As %String(POPSPEC = "Name()");

Property RequestorEmail As %String;

/// If this order is for a account holder,
/// both requestor fields contain Customer information
Relationship AccountHolder As FCE.AccountHolder [ Cardinality = one, Inverse = CurrencyOrders ];

Index AccountHolderIndex On AccountHolder;

/// Unique reference to FCE.Payment
Property Payment As FCE.Payment;

Index PaymentIndex On Payment [ Unique ];

ForeignKey PaymentFK(Payment) References FCE.Payment();

/// If this order requires approval
Relationship Employee As FCE.Employee [ Cardinality = one, Inverse = ApprovedOrders ];

Index EmployeeIndex On Employee;

/// ATM which performs currency exchange
Relationship ATM As FCE.ATM [ Cardinality = one, Inverse = Orders ];

Index ATMIndex On ATM;

Property AmountOut As %Numeric(MINVAL = 0);

Property CurrencyOut As FCE.CurrencyName;

/// AmountIn reduced by transaction fee
Property AmountIn As %Numeric(MINVAL = 0);

Property CurrencyIn As FCE.CurrencyName;

Property ExchangeRate As %Decimal(MINVAL = .001, SCALE = 3);

Property Fee As %Numeric;

Property DateStamp As %Date(MAXVAL = "+$system.SYS.TimeStamp()", MINVAL = 59901);

Property TimeStamp As %Time [ SqlFieldName = TS ];

/// Satisfaction with the service on this order
Property Satisfaction As %String(DISPLAYLIST = "-Great-Good-OK-Bad-Horrible", VALUELIST = "-1-2-3-4-5");

/// Requested: initial request<br>
/// Pending:   only if awaiting approval<br>
/// Rejected:  not approved by bank<br>
/// Paid:      currency received by ATM, outgoing currency to be picked up<br>
/// Completed: outgoing currency paid to customer<br>
/// Problem:   problem in system<br>
/// Canceled:  canceled by customer<br>
Property Status As %String(VALUELIST = "-Requested-Pending-Rejected-Paid-Completed-Problem-Canceled");

Index StatusIndex On Status [ Type = bitmap ];

Index OutIndex On CurrencyOut [ Type = bitmap ];

Index InIndex On CurrencyIn [ Type = bitmap ];

/// When a CurrencyOrder is updated or deleted, record that in the ATM Notes
Trigger UpdateDeleteInNotes [ Event = UPDATE/DELETE, Foreach = row/object, Time = AFTER ]
{
	new changed, note, atm, st // ensure variables are private to trigger
	return:({ATM} = "")   // if this CurrencyOrder has no ATM, just exit
	set changed = $case({%%OPERATION}, "DELETE":"deleted", "UPDATE":"updated")
	set note = "At " _ $zdt($h) _ ", " _ $username _ " " _ changed _ " Order #"
			   _ {ID} _ " originally requested by " _ {Requestor}
	           _ " (for " _ {AmountOut} _ " " _ {CurrencyOut} _ ")"
	set atm = ##class(FCE.ATM).%OpenId({ATM}, 4, .st)
	if $$$ISOK(st) {
	do atm.Notes.MoveToEnd()
	do atm.Notes.WriteLine(note)
	set st = atm.%Save()
	}
	if ($$$ISERR(st)) { set %msg = "Couldn't update ATM notes." }
}

/// This callback method is invoked by the <METHOD>%New</METHOD> method to 
/// provide notification that a new instance of an object is being created.
/// 
/// <P>If this method returns an error then the object will not be created.
/// <p>It is passed the arguments provided in the %New call.
/// When customizing this method, override the arguments with whatever variables and types you expect to receive from %New().
/// For example, if you're going to call %New, passing 2 arguments, %OnNew's signature could be:
/// <p>Method %OnNew(dob as %Date = "", name as %Name = "") as %Status
Method %OnNew(currencyOut As FCE.CurrencyName = "", amountOut As %Numeric = 0, currencyIn As FCE.CurrencyName = "", amountIn As %Numeric = 0, Output errorStatus As %Status) As %Status [ Private, ProcedureBlock = 1, ServerOnly = 1 ]
{
	set ..CurrencyOut = currencyOut
	set ..AmountOut = amountOut
	set ..CurrencyIn = currencyIn
	set ..AmountIn = amountIn
	set ..Status = "Requested"
	set ..Fee = 0
	
	set errorStatus = ..%ValidateObject() // validate the new object
	return errorStatus
}

/// Display all orders in a given status, sorted by branch city
ClassMethod OrdersByCity(orderStatus As %String = "Pending") As %Status
{
	 #sqlcompile SELECT = odbc
	 &sql(declare bycity cursor for
	      select ATM->Branch->Address->City, AmountIn, CurrencyIn,
	      AmountOut, CurrencyOut, DateStamp, TS
          from FCE.CurrencyOrder
          where Status = :orderStatus
          order by ATM->Branch->Address->City)
     &sql(open bycity)
     write !, orderStatus, " Orders"
	 write !, "City", ?20, "Amount In", ?30, "Currency In", ?55, "Amount Out", ?70,
	              "Currency Out", ?95, "Date Stamp", ?110, "Time Stamp"
     for {
	     &sql(fetch bycity into :city, :amountIn, :currencyIn, :amountOut,
	                             :currencyOut, :dateStamp, :timeStamp)
	     quit:(SQLCODE '= 0)
	     write !, city, ?20, amountIn, ?30, currencyIn, ?55, amountOut, ?70,
	              currencyOut, ?95, dateStamp, ?110, timeStamp
     }
     
	if SQLCODE = 100 {
	    write !!, %ROWCOUNT, " row(s) returned."
	    set status = $$$OK
	}
	else { set status = $$$ERROR($$$GeneralError, "SQLCODE: " _ SQLCODE _ " " _ %msg) }
     &sql(close bycity)
     return status
}

Method OnPopulate() As %Status
{
	// assign a random payment to this CurrencyOrder
	set rand = $random(3), payment = 1
	if (rand = 0) { do ##class(FCE.Cash).Populate(1,,, .payment) }
	elseif (rand = 1) { do ##class(FCE.CreditCard).Populate(1,,, .payment)}
	elseif (rand = 2) { do ##class(FCE.AccountPayment).Populate(1,,, .payment)}
	set ..Payment = payment(1)
	// only CurrencyOrders with AccountPayments have an AccountHolder
	if (rand '= 2) { set ..AccountHolder = "" }
	// 80% of CurrencyOrders don't require Employee approval
	if ($random(10) > 1) { set ..Employee = "" }
	// only 10% of CurrencyOrders happen at a Branch (no ATM)
	if ($random(10) = 0) { set ..ATM = "" }
	// 80% CurrencyOrders are Status = Completed
	if ($random(10) > 1) {
		set ..Status = "Completed"
	}
	else {
		set ..Status = ##class(%PopulateUtils).ValueList("-Requested-Pending-Rejected-Paid-Problem-Canceled")
	}
	// make sure CurrencyIn and CurrencyOut are different
	while (..CurrencyIn = ..CurrencyOut) {
		set ..CurrencyOut = ##class(FCE.Currency).Currency()
	}
	// set fee
	set ..Fee = ..AmountIn * .025
	// get exchange rate
	set rate = ##class(FCE.Currency).ComputeRate(..CurrencyIn, ..CurrencyOut)
	set ..ExchangeRate = rate
	// set correct AmountOut
	set ..AmountOut = (..AmountIn - ..Fee) * rate
	return $$$OK
}

/// When a currency order row/object is deleted, delete its payment
Trigger DeletePayment [ Event = DELETE, Foreach = row/object, Time = AFTER ]
{
	return:({Payment} = "")
    new SQLCODE // ensure SQLCODE is private to trigger
    &sql(delete from FCE.Payment where ID = :{Payment})
	if (SQLCODE < 0) { set %ok = 0, %msg = "SQLCODE: "_ SQLCODE }
}

Storage Default
{
<Data name="CurrencyOrderDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Requestor</Value>
</Value>
<Value name="3">
<Value>RequestorEmail</Value>
</Value>
<Value name="4">
<Value>AccountHolder</Value>
</Value>
<Value name="5">
<Value>Payment</Value>
</Value>
<Value name="6">
<Value>Employee</Value>
</Value>
<Value name="7">
<Value>ATM</Value>
</Value>
<Value name="8">
<Value>AmountOut</Value>
</Value>
<Value name="9">
<Value>CurrencyOut</Value>
</Value>
<Value name="10">
<Value>AmountIn</Value>
</Value>
<Value name="11">
<Value>CurrencyIn</Value>
</Value>
<Value name="12">
<Value>ExchangeRate</Value>
</Value>
<Value name="13">
<Value>Fee</Value>
</Value>
<Value name="14">
<Value>DateStamp</Value>
</Value>
<Value name="15">
<Value>TimeStamp</Value>
</Value>
<Value name="16">
<Value>Satisfaction</Value>
</Value>
<Value name="17">
<Value>Status</Value>
</Value>
</Data>
<DataLocation>^FCE.CurrencyOrderD</DataLocation>
<DefaultData>CurrencyOrderDefaultData</DefaultData>
<ExtentSize>130</ExtentSize>
<IdLocation>^FCE.CurrencyOrderD</IdLocation>
<IndexLocation>^FCE.CurrencyOrderI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>2.31</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="ATM">
<AverageFieldSize>5.54</AverageFieldSize>
<Selectivity>6.2500%</Selectivity>
</Property>
<Property name="AccountHolder">
<AverageFieldSize>.52</AverageFieldSize>
<OutlierSelectivity>.684615:</OutlierSelectivity>
<Selectivity>2.1026%</Selectivity>
</Property>
<Property name="AmountIn">
<AverageFieldSize>6.8</AverageFieldSize>
<Selectivity>0.7692%</Selectivity>
</Property>
<Property name="AmountOut">
<AverageFieldSize>7.02</AverageFieldSize>
<Selectivity>0.7692%</Selectivity>
</Property>
<Property name="CurrencyIn">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>10.0000%</Selectivity>
</Property>
<Property name="CurrencyOut">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>10.0000%</Selectivity>
</Property>
<Property name="DateStamp">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>0.7692%</Selectivity>
</Property>
<Property name="Employee">
<AverageFieldSize>.32</AverageFieldSize>
<OutlierSelectivity>.769231:</OutlierSelectivity>
<Selectivity>1.9231%</Selectivity>
</Property>
<Property name="ExchangeRate">
<AverageFieldSize>4.61</AverageFieldSize>
<Selectivity>1.4493%</Selectivity>
</Property>
<Property name="Fee">
<AverageFieldSize>5.38</AverageFieldSize>
<Selectivity>0.7813%</Selectivity>
</Property>
<Property name="Payment">
<AverageFieldSize>2.33</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Requestor">
<AverageFieldSize>16.07</AverageFieldSize>
<Selectivity>0.7692%</Selectivity>
</Property>
<Property name="RequestorEmail">
<AverageFieldSize>4.92</AverageFieldSize>
<Selectivity>0.7692%</Selectivity>
</Property>
<Property name="Satisfaction">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>20.0000%</Selectivity>
</Property>
<Property name="Status">
<AverageFieldSize>8.55</AverageFieldSize>
<OutlierSelectivity>.792308:"Completed"</OutlierSelectivity>
<Selectivity>3.4615%</Selectivity>
</Property>
<Property name="TimeStamp">
<AverageFieldSize>4.88</AverageFieldSize>
<Selectivity>0.7692%</Selectivity>
</Property>
<SQLMap name="$CurrencyOrder">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="ATMIndex">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="AccountHolderIndex">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="EmployeeIndex">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="IDKEY">
<BlockCount>-8</BlockCount>
</SQLMap>
<SQLMap name="InIndex">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="OutIndex">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="PaymentIndex">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="StatusIndex">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^FCE.CurrencyOrderS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
