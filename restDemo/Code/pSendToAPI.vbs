Const URL_UPLOAD_DOCUMENT = "https://asworkflow.azurewebsites.net/api/documents"

Const SECURITY_TOKEN = "123"

Sub SendToAPI_OnLoad
	EKOManager.StatusMessage ("documentTypeId = " & documentTypeId)
	EKOManager.StatusMessage ("borrowerId = " & borrowerId)

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
			Dim resp : resp = SendDocument(documentTypeId, borrowerId, KDocument.FilePath)
			EKOManager.StatusMessage ("resp (should be 201) = " & resp)
		End If
	End If

End Sub

Sub SendToAPI_OnUnload

End Sub

' Uncomment below to test
' Call SendDocument(1, 2, "C:\AutoStoreWorkflows\restDemo\Samples\FORM203.pdf")
Function SendDocument(documentTypeId, borrowerId, DocPath)

	Set HTTP = CreateObject("Microsoft.XMLHTTP")

	Dim inByteArray: inByteArray = ReadBinaryFile(docPath)
	Dim base64Encoded: base64Encoded = encodeBase64(inByteArray)

	url = URL_UPLOAD_DOCUMENT

	Dim jsonData
	' msgbox base64Encoded
	Dim cleanFile : cleanFile = Replace(Trim(CStr(base64Encoded)), vbLf, "")
	' msgbox cleanFile

	jsonData = "{""documentTypeId"": " & documentTypeId & ", ""borrowerId"": " & borrowerId & ", ""file"": """ & cleanFile &  """ }"

	Set fs = CreateObject("Scripting.FileSystemObject")
	Set objFile = fs.CreateTextFile("C:\AutoStoreWorkflows\restDemo\Output\out.json", True)
	objFile.Write jsonData
	objFile.Close

	HTTP.Open "POST", url, False
	HTTP.setRequestHeader "Content-Type", "application/json"
	HTTP.setRequestHeader "Authorization", "Bearer " & SECURITY_TOKEN
	HTTP.send jsonData

	' msgbox HTTP.responseText
	SendDocument = HTTP.status ' Expect 201, need to fail if not
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
