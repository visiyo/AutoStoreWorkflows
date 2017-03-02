'LoadAssembly:System.Web.Extensions.dll

' Be sure to copy the dll System.WebExtensions.dll into the AutoStore directory in "Program Files"
' SEE README.md for more details

Option Strict Off

Imports System
Imports NSi.AutoStore.Capture.DataModel
Imports System.Net
Imports System.Web
Imports System.IO
Imports System.Text
Imports System.Web.Script.Serialization

Module Script
	Const SECURITY_TOKEN As String = "uyhk3cy427rqc5mzsrewu2wz" ' REPLACE WITH YOUR KEY HERE https://developer.athenahealth.com/io-docs

    Sub Form_OnLoad(ByVal eventData As MFPEventData)
		' Call GetPatients(eventData, "smith")
	End Sub

	Sub Form_OnSubmit(ByVal eventData As MFPEventData)
        'TODO add code here to execute when the user presses OK in the form
    End Sub

	Sub Search_OnChange(ByVal eventData As MFPEventData)
		'TODO add code here to execute when field value of <fieldName> is changed
		Dim searchField As TextField = eventData.Form.Fields.GetField("Search")
		Dim term as String = searchField.Value
		GetPatients(eventData, term)
    End Sub

	Sub GetPatients(ByVal eventData As MFPEventData, ByVal term As String)
		Dim url As String = "https://api.athenahealth.com/preview1/195900/patients?guarantorcountrycode3166=US&limit=100"
		If term.Length > 0 Then
			url = url & "&lastname=" & term
		End If

		Dim address As Uri = New Uri(url)

		Dim request As HttpWebRequest = DirectCast(WebRequest.Create(address), HttpWebRequest)
		request.Method = "GET"
		request.ContentType = "application/json"
		request.Headers.Add("Authorization", "Bearer " & SECURITY_TOKEN)

		Dim response As HttpWebResponse = DirectCast(request.GetResponse(), HttpWebResponse)
		Dim reader As StreamReader = New StreamReader(response.GetResponseStream())

		Dim json As String = reader.ReadToEnd()
		If Not response Is Nothing Then response.Close()
		Dim serializer As JavaScriptSerializer = New JavaScriptSerializer()
		Dim results As  System.Collections.Generic.Dictionary(Of String, Object) = serializer.Deserialize(Of System.Collections.Generic.Dictionary(Of String, Object))(json)
		Dim patients As System.Collections.ArrayList = results.Item("patients")

		Dim patientList As ListField = eventData.Form.Fields.GetField("PatientId")

		patientList.FindMode = False
		patientList.Items.Clear()

		Dim patient As Object
		For Each patient In patients
			Dim label As String = patient.Item("firstname") & " " & patient.Item("lastname") & " - " & patient.Item("patientid")

			Dim patientItem As listItem = New ListItem(label, patient.Item("patientid"))
			patientList.Items.Add(patientItem)
		Next

	End Sub
End Module
