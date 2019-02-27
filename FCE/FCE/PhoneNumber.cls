Class FCE.PhoneNumber Extends %String
{

Parameter PATTERN = "3n1""-""3n1""-""4n";

/// Converts the value of <var>%val</var>, which is in logical format, into a display string. Removes all the null characters from the string.
/// <p>Returns the string value of <var>%val</var>.
ClassMethod LogicalToDisplay(%val As %String) As %String
{
	return "(" _ $piece(%val, "-") _ ")-" _ $piece(%val, "-", 2, 3)
}

}
