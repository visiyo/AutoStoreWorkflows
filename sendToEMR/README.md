# REST Demo

## Overview
Need to scan or send documents to an EMR?

In this repo, I'm showing how to use AutoStore to search for a patient and scan documents to a REST API.

As of now, this repo just shows using a Samsung MFD to scan to Athena Health's Rest API, but we'll add more over time.

Athena Health REST API: https://developer.athenahealth.com/io-docs
Register for a developer's account (you'll need this for access tokens): https://developer.athenahealth.com/member/register

### AutoStore components used
- Samsung (Capture) - VB.net configuring REST API HTT GET to retrieve patients
- AutoCapture (Capture) - VBScript configuring Rest API HTTP GET to retrieve patients
- VBScript (Route) - VBScript configuring Rest API HTTP POST to send documents

## Repo
https://github.com/visiyo/AutoStoreWorkflows/tree/master/sendToEMR

## Version
1.0

## Installation
Run this code from this directory
`C:\AutoStoreWorkflows\sendToEMR`

**Before running AutoStore, open every task, and every capture component.  Then click "ok".  This will auto create all temp directories**

**Be sure to copy the file /tools/System.Web.Extensions.dll to the AutoStore directory in Progam Files**

## Video
Demo and training video here: https://youtu.be/_P3Xlh3Su0o

## Contact
Nick Caruso
info@visiyo.com with any questions

## License
MIT
