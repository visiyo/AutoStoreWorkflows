Const SECURITY_TOKEN = "dphykpgcta38a4t36vh8r8r6"
' Const SECURITY_TOKEN = "123"

Sub SendToAPI_OnLoad
	EKOManager.StatusMessage ("patientId = " & patientId)

	Set KDocument = KnowledgeObject.GetFirstDocument
	If Not(KDocument Is Nothing) Then
		Set PTopic = KnowledgeObject.GetPersistenceTopic()
		Set Topic  = KnowledgeContent.GetTopicInterface

		If Not(Topic Is Nothing) Then
			'get Persistence topic to check tag so we don't process same KO again
			Set MyTagEntry = PTopic.GetEntry( "SplitDocument",0 )
			Set objFSO = CreateObject("Scripting.FileSystemObject")
			Set objFile = objFSO.GetFile(KDocument.FilePath)
			Dim originalFileName : originalFileName = objFSO.GetBaseName(objFile)

			EKOManager.StatusMessage ("New document at = " &  KDocument.FilePath)
			Dim resp : resp = SendDocument(patientId, KDocument.FilePath)
			EKOManager.StatusMessage ("resp (should be 201) = " & resp)
		End If
	End If

End Sub

Sub SendToAPI_OnUnload

End Sub

' Uncomment below to test
Call SendDocument(33, "C:\AutoStoreWorkflows\sendToEMR\Samples\sample.pdf")
Function SendDocument(patientId, DocPath)

	Set HTTP = CreateObject("Microsoft.XMLHTTP")

	Dim FileContents: FileContents = ReadBinaryFile(docPath)
	Dim FieldName: FieldName = "attachmentcontents"
	
	Const Boundary = "---------------------------athenaUploadBoundary"

	Dim FormData: FormData = BuildFormData(FileContents, Boundary, "Scan.pdf", FieldName)
	' msgbox FormData
	url = "https://api.athenahealth.com/preview1/195900/patients/" & patientId & "/documents"
	' url = "https://spark.ngrok.io/api/documents-multipart"
	' msgbox url
	
	HTTP.Open "POST", url, False
	HTTP.setRequestHeader "Content-Type", "multipart/form-data; boundary=" & Boundary & vbcrlf
	HTTP.setRequestHeader "Authorization", "Bearer " & SECURITY_TOKEN
	On Error Resume Next
	HTTP.send FormData
	If Err.Number <> 0 Then
		msgbox Err.Description		
	Else
		msgbox HTTP.status
		msgbox HTTP.StatusText
	End If
	

	' msgbox HTTP.responseText
	SendDocument = HTTP.status ' Expect 201, need to fail if not
End Function

'Build multipart/form-data document with file contents And header info
Function BuildFormData(FileContents, Boundary, FileName, FieldName)
	Dim FormData, Pre, Po
	Const ContentType = "application/upload"
  
	'The two parts around file contents In the multipart-form data.
	Pre = "--" + Boundary + vbCrLf + mpFields(FieldName, FileName, ContentType)
	' Po = vbCrLf + "--" + Boundary + "--" + vbCrLf

	Po = vbCrLf + "--" + Boundary + vbCrLf + "Content-Disposition: form-data; name=""documentsubclass""" + vbCrlf + vbCrlf & _
		"ADMIN_CONSENT" & _
		vbCrlf & "--" + Boundary + "--" + vbCrlf
	
	'Build form data using recordset binary field
	Const adLongVarBinary = 205
	Dim RS: Set RS = CreateObject("ADODB.Recordset")
	RS.Fields.Append "b", adLongVarBinary, Len(Pre) + LenB(FileContents) + Len(Po)
	RS.Open
	RS.AddNew
	Dim LenData
	'Convert Pre string value To a binary data
	LenData = Len(Pre)
	RS("b").AppendChunk (StringToMB(Pre) & ChrB(0))
	Pre = RS("b").GetChunk(LenData)
	RS("b") = ""
    
	'Convert Po string value To a binary data
	LenData = Len(Po)
	RS("b").AppendChunk (StringToMB(Po) & ChrB(0))
	Po = RS("b").GetChunk(LenData)
	RS("b") = ""
    
	'Join Pre + FileContents + Po binary data
	RS("b").AppendChunk (Pre)
	RS("b").AppendChunk (FileContents)
	RS("b").AppendChunk (Po)
	
	RS.Update
	FormData = RS("b")
	RS.Close

	BuildFormData = FormData
End Function

'Converts OLE string To multibyte string
Function StringToMB(S)
	Dim I, B
	For I = 1 To Len(S)
		B = B & ChrB(Asc(Mid(S, I, 1)))
	Next
	StringToMB = B
End Function

' Form field header.
Function mpFields(FieldName, FileName, ContentType)
	Dim MPTemplate 'template For multipart header
	MPTemplate = "Content-Disposition: form-data; name=""{field}"";" + _
	" filename=""{file}""" + vbCrLf + _
		"Content-Type: {ct}" + vbCrLf + vbCrLf
	Dim Out
	Out = Replace(MPTemplate, "{field}", FieldName)
	Out = Replace(Out, "{file}", FileName)
	mpFields = Replace(Out, "{ct}", ContentType)
End Function


Function ReadBinaryFile(FileName)
	Const adTypeBinary = 1

	'Create Stream object
	Dim BinaryStream
	Set BinaryStream = CreateObject("ADODB.Stream")

	'Specify stream type - we want To get binary data.
	BinaryStream.Type = adTypeBinary

	'Open the stream
	BinaryStream.Open

	'Load the file data from disk To stream object
	BinaryStream.LoadFromFile FileName

	'Open the stream And get binary data from the object
	ReadBinaryFile = BinaryStream.Read
End Function

private function encodeBase64(bytes)
	Dim DM, EL
	Set DM = CreateObject("Microsoft.XMLDOM")
	' Create temporary node with Base64 data type
	Set EL = DM.createElement("tmp")
	EL.DataType = "bin.base64"
	' Set bytes, get encoded String
	EL.NodeTypedValue = bytes
	encodeBase64 = EL.Text
End Function

