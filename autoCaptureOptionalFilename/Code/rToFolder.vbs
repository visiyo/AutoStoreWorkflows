Sub rToFolder_OnLoad
	EKOManager.StatusMessage ("filename = " & filename)

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

			EKOManager.StatusMessage ("original filename  = " & originalFileName)
			If (filename = "~ASX::%filename%~") Then
				Topic.Replace "~USR::filename~", originalFileName
			Else 
				Topic.Replace "~USR::filename~", filename
			End If
		End If
	End If
End Sub

Sub rToFolder_OnUnload

End Sub
