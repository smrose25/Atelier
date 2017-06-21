/// Address properties for <class>FCE.RealEstate</class> and <class>FCE.MailingAddress</class>
Class FCE.Address Extends (%Populate, %XML.Adaptor) [ Abstract ]
{

Property Street As %String [ Required ];

Property City As %String [ Required ];

Property State As %String(MAXLEN = 2, VALUELIST = "-NY-NJ-MA-TX") [ Required ];

Property Zip As %String(MAXLEN = 10, PATTERN = "5n.1(1""-""4n)") [ Required ];

Method Print()
{
	write !, ..Street
	write !, ..City, ", ", ..State, " ", ..Zip
}

}
