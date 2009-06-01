<!---

--->


<cfcomponent name="NVPGatewayTest" extends="mxunit.framework.TestCase" output="false">

	<cfset variables.cfpaymentCore = "null" />
	<cfset variables.gateway = "null" />

	<cffunction name="setUp" returntype="void" access="public">

		<cfset var config = structNew() />

		<cfscript>
			config.path = "paypal.wpp.NVPGateway";
			config.username = "paypal_1243142215_biz_api1.lamoree.com";
			config.password = "1243142227";
			config.signature = "AFcWxV21C7fd0v3bYYYRCpSSRl31AD632SuLIOLLihiymINoOCODKW62";
			config.testmode = true;

			variables.cfpaymentCore = createObject("component", "cfpayment.api.core").init(config=config);
			variables.gateway = variables.cfpaymentCore.getGateway();
		</cfscript>
	</cffunction>

	<cffunction name="testPurchase" access="public" returntype="void" output="false">

		<cfset var money = variables.cfpaymentCore.createMoney(cents=5000) />
		<cfset var gw = variables.gateway />
		<cfset var response = "null" />
		<cfset var options = structNew() />

		<cfset options.email = "unittest@lamoree.com" />
		<cfset options.ipAddress = "64.81.35.1" />
		<cfset options.company = "Lamoree Software" />
		<cfset options.description = "Test Transaction" />

		<cfset response = gw.purchase(money=money, account=createValidCard(), options=options) />
		<cfset assertTrue(response.getSuccess(), "The purchase should have succeeded.") />

		<cfset response = gw.purchase(money=money, account=createInvalidCard(), options=options) />
		<cfset assertTrue(not response.getSuccess(), "The purchase should not have succeeded, due to invalid credit card.") />

<!---
		<cfset response = gw.purchase(money = money, account = createValidCardWithoutCVV(), options = options) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />
		<cfset debug(response.getCVVMessage()) />
		<cfset assertTrue(response.getCVVCode() EQ "", "No CVV was passed so no answer should be provided but was: '#response.getCVVCode()#'") />

		<cfset response = gw.purchase(money = money, account = createValidCardWithBadCVV(), options = options) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />
		<cfset debug(response.getCVVMessage()) />
		<cfset assertTrue(response.getCVVCode() EQ "N", "Bad CVV was passed so non-matching answer should be provided but was: '#response.getCVVCode()#'") />

		<cfset response = gw.purchase(money = money, account = createValidCardWithoutStreetMatch(), options = options) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />
		<cfset debug(response.getAVSMessage()) />
		<cfset assertTrue(response.getAVSCode() EQ "Z", "AVS Zip match only should be found") />

		<cfset response = gw.purchase(money = money, account = createValidCardWithoutZipMatch(), options = options) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />
		<cfset debug(response.getAVSMessage()) />
		<cfset assertTrue(response.getAVSCode() EQ "A", "AVS Street match only should be found") />


		<!--- test the purchase method for EFT --->
		<cfset response = gw.purchase(money = money, account = createValidEFT(), options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />

		<!--- amounts less than 1.00 generate declines --->
		<cfset response = gw.purchase(money = variables.cfpaymentCore.createMoney(50), account = createValidEFT(), options = options) />
		<cfset assertTrue(NOT response.getSuccess(), "The authorization did succeed") />

--->

	</cffunction>

<!---

	<cffunction name="testAuthorizeOnly" access="public" returntype="void" output="false">

		<cfset var money = variables.cfpaymentCore.createMoney(5000) /><!--- in cents, $50.00 --->
		<cfset var response = "" />
		<cfset var options = structNew() />

		<cfset response = gw.authorize(money = money, account = createValidCard(), options = options) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />
		<cfset debug(response.getAVSMessage()) />
		<cfset assertTrue(response.getAVSCode() EQ "Y", "Exact match (street + zip) should be found") />

		<!--- amounts less than 1.00 generate declines --->
		<cfset response = gw.authorize(money = variables.cfpaymentCore.createMoney(50), account = createValidCard(), options = options) />
		<cfset assertTrue(NOT response.getSuccess(), "The authorization did succeed") />

		<!--- this will be rejected by gateway because the card number is not valid --->
		<cfset response = gw.authorize(money = money, account = createInvalidCard(), options = options) />
		<cfset assertTrue(NOT response.getSuccess(), "The authorization did succeed") />


		<cfset response = gw.authorize(money = money, account = createValidCardWithoutCVV(), options = options) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />
		<cfset debug(response.getCVVMessage()) />
		<cfset assertTrue(response.getCVVCode() EQ "", "No CVV was passed so no answer should be provided but was: '#response.getCVVCode()#'") />

		<cfset response = gw.authorize(money = money, account = createValidCardWithBadCVV(), options = options) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />
		<cfset debug(response.getCVVMessage()) />
		<cfset assertTrue(response.getCVVCode() EQ "N", "Bad CVV was passed so non-matching answer should be provided but was: '#response.getCVVCode()#'") />

		<cfset response = gw.authorize(money = money, account = createValidCardWithoutStreetMatch(), options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />
		<cfset debug(response.getAVSMessage()) />
		<cfset assertTrue(response.getAVSCode() EQ "Z", "AVS Zip match only should be found") />

		<cfset response = gw.authorize(money = money, account = createValidCardWithoutZipMatch(), options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />
		<cfset debug(response.getAVSMessage()) />
		<cfset assertTrue(response.getAVSCode() EQ "A", "AVS Street match only should be found") />

	</cffunction>


	<cffunction name="testAuthorizeAndStoreThenPurchase" access="public" returntype="void" output="false">

		<cfset var money = variables.cfpaymentCore.createMoney(5000) /><!--- in cents, $50.00 --->
		<cfset var token = variables.cfpaymentCore.createToken(createUUID()) />
		<cfset var response = "" />
		<cfset var options = structNew() />
		<cfset var vault = structNew() />
		<cfset options["tokenId"] = token.getID() />
		<cfset options["tokenize"] = true />

		<cfset response = gw.authorize(money = money, account = createValidCard(), options = options) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />

		<cfset response = gw.purchase(money = money, account = token, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The token-based purchase did not succeed") />

	</cffunction>


	<cffunction name="testStoreAndUnstoreCreditCard" access="public" returntype="void" output="false">

		<cfset var money = variables.cfpaymentCore.createMoney(5000) /><!--- in cents, $50.00 --->
		<cfset var response = "" />
		<cfset var options = structNew() />
		<cfset var token = variables.cfpaymentCore.createToken(createUUID()) />

		<!--- try storing withOUT a populated token value --->
		<cfset response = gw.store(account = createValidCard(), options = options) />
		<cfset token.setID(response.getTokenID()) />
		<cfset assertTrue(response.getSuccess(), "The store did not succeed") />


		<!--- get the masked details --->
		<cfset options = { tokenId = token.getID(), report_type = "customer_vault" } />
		<cfset response = gw.status(options = options) />
		<cfset debug(response.getParsedResult()) />
		<cfset options = { } />

		<!--- unstore, using whatever they gave us as a token ID --->
		<cfset response = gw.unstore(account = token, options = options) />
		<cfset assertTrue(response.getSuccess(), "The unstore did not succeed") />


		<!--- try storing with a populated token value --->
		<cfset token = variables.cfpaymentCore.createToken(createUUID()) />
		<cfset options["tokenId"] = token.getID() />
		<cfset response = gw.store(account = createValidCard(), options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The store did not succeed") />
		<cfset assertTrue(response.getTokenID() EQ token.getID(), "The submitted token ID was not returned, sent #token.getID()#, received: #response.getParsedResult().customer_vault_id#") />

		<cfset response = gw.unstore(account = token, options = options) />
		<cfset assertTrue(response.getSuccess(), "The unstore did not succeed") />

	</cffunction>


	<cffunction name="testStoreAndUnstoreEFT" access="public" returntype="void" output="false">

		<cfset var money = variables.cfpaymentCore.createMoney(5100) /><!--- in cents, $50.00 --->
		<cfset var response = "" />
		<cfset var options = structNew() />
		<cfset var token = variables.cfpaymentCore.createToken(createUUID()) />

		<!--- try storing withOUT a populated token value --->
		<cfset response = gw.store(account = createValidEFT(), options = options) />
		<cfset token.setID(response.getTokenID()) />
		<cfset assertTrue(response.getSuccess(), "The store did not succeed") />


		<!--- get the masked details --->
		<cfset options = { tokenId = token.getID(), report_type = "customer_vault" } />
		<cfset response = gw.status(options = options) />
		<cfset debug(response.getParsedResult()) />
		<cfset options = { } />

		<!--- unstore, using whatever they gave us as a token ID --->
		<cfset response = gw.unstore(account = token, options = options) />
		<cfset assertTrue(response.getSuccess(), "The unstore did not succeed") />


		<!--- try storing with a populated token value --->
		<cfset token = variables.cfpaymentCore.createToken(createUUID()) />
		<cfset options["tokenId"] = token.getID() />
		<cfset response = gw.store(account = createValidEFT(), options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The store did not succeed") />
		<cfset assertTrue(response.getTokenID() EQ token.getID(), "The submitted token ID was not returned, sent #token.getID()#, received: #response.getParsedResult().customer_vault_id#") />

		<cfset response = gw.unstore(account = token, options = options) />
		<cfset assertTrue(response.getSuccess(), "The unstore did not succeed") />

	</cffunction>


	<!--- confirm authorize throws error --->
	<cffunction name="testAuthorizeThrowsException" access="public" returntype="void" output="false">

		<cfset var money = variables.cfpaymentCore.createMoney(5000) /><!--- in cents, $50.00 --->
		<cfset var response = "" />
		<cfset var options = structNew() />

		<!--- authorize will throw an error for e-check --->
		<cftry>
			<cfset response = gw.authorize(money = money, account = createValidEFT(), options = options) />
			<cfset assertTrue(false, "EFT authorize() should fail but did not") />
			<cfcatch type="cfpayment.MethodNotImplemented">
				<cfset assertTrue(true, "EFT authorize() threw cfpayment.MethodNotImplemented") />
			</cfcatch>
		</cftry>

	</cffunction>


	<cffunction name="testAuthorizeThenCaptureThenReport" access="public" returntype="void" output="false">

		<cfset var account = createValidCard() />
		<cfset var money = variables.cfpaymentCore.createMoney(5000) /><!--- in cents, $50.00 --->
		<cfset var response = "" />
		<cfset var report = "" />
		<cfset var options = structNew() />
		<cfset var tid = "" />


		<cfset response = gw.authorize(money = money, account = account, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />

		<!--- braintree (like itransact), uses its own transaction/InternalID for capturing an authorization.  Is authorization even used by anyone? --->
		<cfset response = gw.capture(money = money, authorization = response.getTransactionId(), options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The capture did not succeed") />

		<!--- now run a detail report on this transaction --->
		<cfset report = gw.status(transactionid = response.getTransactionID()) />
		<cfset debug(report.getMemento()) />
		<cfset assertTrue(report.getSuccess() AND NOT report.hasError(), "Successful transactionid should have success = true") />

		<!--- pass a non-existent id to see how error is handled --->
		<cfset report = gw.status(transactionid = "11111111") />
		<cfset debug(report.getMemento()) />
		<cfset assertTrue(report.getSuccess() AND arrayLen(report.getParsedResult().xmlRoot.xmlChildren) EQ 0, "Invalid transactionid should result in no returned matches") />

		<!--- use a broken request to see how error is handled
		<cfset options["condition"] = 'unknown' />
		<cfset options["cc_number"] = '5454' />
		<cfset options["start_date"] = '2008-03-10' />
		<cfset options["end_date"] = '2008-03-08' />
		<cfset report = gw.status(options = options) />
		<cfset debug(report.getMemento()) />
		<cfset assertTrue(report.hasError(), "Invalid options should trigger a gateway failure (response code 3)") />
		--->

	</cffunction>


	<cffunction name="testAuthorizeThenCredit" access="public" returntype="void" output="false">

		<cfset var account = createValidCard() />
		<cfset var money = variables.cfpaymentCore.createMoney(5000) /><!--- in cents, $50.00 --->
		<cfset var response = "" />
		<cfset var report = "" />
		<cfset var options = structNew() />


		<cfset response = gw.authorize(money = money, account = account, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />

		<cfset response = gw.credit(transactionid = response.getTransactionID(), money = money, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(NOT response.getSuccess(), "You cannot credit a preauth") />

	</cffunction>


	<cffunction name="testAuthorizeThenVoid" access="public" returntype="void" output="false">

		<cfset var account = createValidCard() />
		<cfset var money = variables.cfpaymentCore.createMoney(5000) /><!--- in cents, $50.00 --->
		<cfset var response = "" />
		<cfset var report = "" />
		<cfset var options = structNew() />


		<cfset response = gw.authorize(money = money, account = account, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />

		<cfset response = gw.void(transactionid = response.getTransactionID(), options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "You can void a preauth") />

	</cffunction>


	<cffunction name="testPurchaseThenCredit" access="public" returntype="void" output="false">

		<cfset var account = createValidCard() />
		<cfset var money = variables.cfpaymentCore.createMoney(5000) /><!--- in cents, $50.00 --->
		<cfset var response = "" />
		<cfset var report = "" />
		<cfset var options = structNew() />


		<cfset response = gw.purchase(money = money, account = account, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The purchase did not succeed") />

		<cfset response = gw.credit(transactionid = response.getTransactionID(), money = money, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "You can credit a purchase") />

	</cffunction>


	<cffunction name="testPurchaseThenVoidThenReport" access="public" returntype="void" output="false">

		<cfset var account = createValidCard() />
		<cfset var money = variables.cfpaymentCore.createMoney(5000) /><!--- in cents, $50.00 --->
		<cfset var response = "" />
		<cfset var report = "" />
		<cfset var options = structNew() />


		<cfset response = gw.purchase(money = money, account = account, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The purchase did not succeed") />

		<cfset response = gw.void(transactionid = response.getTransactionID(), options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "You can void a purchase") />

		<cfset report = gw.status(transactionid = response.getTransactionID()) />
		<cfset debug(report.getMemento()) />
		<cfset assertTrue(report.getSuccess() AND arrayLen(report.getParsedResult().xmlRoot.xmlChildren) GT 0, "Transactionid should result in matches") />

	</cffunction>


	<cffunction name="testDirectDepositEFT" access="public" returntype="void" output="false">

		<cfset var account = variables.cfpaymentCore.createEFT() />
		<cfset var money = variables.cfpaymentCore.createMoney(500) /><!--- in cents, $5000.00 --->
		<cfset var response = "" />
		<cfset var report = "" />
		<cfset var options = structNew() />

		<cfset account.setAccount("22034-234233") />
		<cfset account.setRoutingNumber("121000358") />
		<cfset account.setFirstName("Test Account") />
		<cfset account.setAccountType("checking") />
		<cfset account.setSEC("CCD") />

		<cfset response = gw.credit(money = money, account = account, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The direct deposit did not succeed") />

	</cffunction>


	<cffunction name="testPurchaseThenVoidEFT" access="public" returntype="void" output="false">

		<cfset var account = createValidEFT() />
		<cfset var money = variables.cfpaymentCore.createMoney(4400) /><!--- in cents, $50.00 --->
		<cfset var response = "" />
		<cfset var options = structNew() /><!--- required for EFT voids --->

		<!--- validate object --->
		<cfset assertTrue(account.getIsValid(), "EFT is not valid") />

		<!--- first try to purchase --->
		<cfset response = gw.purchase(money = money, account = account, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The purchase did not succeed") />

		<!--- then try to void transaction --->
		<cfset options["payment"] = "check" />
		<cfset response = gw.void(transactionid = response.getTransactionID(), options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The void did not succeed") />

	</cffunction>



	<cffunction name="testPurchaseThenCreditEFT" access="public" returntype="void" output="false">

		<cfset var account = createValidEFT() />
		<cfset var money = variables.cfpaymentCore.createMoney(5000) /><!--- in cents, $50.00 --->
		<cfset var response = "" />
		<cfset var report = "" />
		<cfset var options = structNew() />


		<cfset response = gw.purchase(money = money, account = account, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The purchase did not succeed") />

		<cfset response = gw.credit(account = account, money = money, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "You can credit a purchase") />

	</cffunction>


	<cffunction name="testUpperCaseParameters" access="public" returntype="void" output="false">

		<!--- gateway will lower-case all params per BT requirements: transactionId not valid, but transactionid valid --->
		<cfset report = gw.status(TransactionId = "11111111") />
		<cfset debug(report.getMemento()) />
		<cfset assertTrue(report.getSuccess() AND arrayLen(report.getParsedResult().xmlRoot.xmlChildren) EQ 0, "Invalid transactionid should result in no returned matches") />

	</cffunction>
--->
<!---
	<cffunction name="testInvalidPurchases" access="public" returntype="void" output="false">

		<cfset var account = variables.cfpaymentCore.createCreditCard() />
		<cfset var money = variables.cfpaymentCore.createMoney(5000) /><!--- in cents, $50.00 --->
		<cfset var response = "" />
		<cfset var options = structNew() />

		<cfset account.setAccount(5454545454545451) />
		<cfset account.setMonth(12) />
		<cfset account.setYear(year(now())+1) />
		<cfset account.setVerificationValue(123) />
		<cfset account.setFirstName("John") />
		<cfset account.setLastName("Doe") />
		<cfset account.setAddress("236 N. Santa Cruz Ave") />
		<cfset account.setPostalCode("95030") />

		<cfset options.ExternalID = createUUID() />

		<!--- 5451 card will result in an error --->
		<cfset response = gw.purchase(money = money, account = account, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(NOT response.getSuccess(), "The purchase did not fail with invalid CC") />

		<cfset account.setAccount(5454545454545454) />

		<!--- try invalid expiration --->
		<cfset account.setMonth(13) />
		<cfset account.setYear(year(now()) + 1) />
		<cfset response = gw.purchase(money = money, account = account, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(NOT response.getSuccess(), "The purchase did not fail with invalid expiration date") />

		<!--- try expired card --->
		<cfset account.setMonth(5) />
		<cfset account.setYear(year(now()) - 1) />
		<cfset response = gw.purchase(money = money, account = account, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "iTransact gateway does not validate the expiration date so test gateway won't throw error; it is the acquiring bank's responsibility to validate/enforce it") />

	</cffunction>
--->


	<cffunction name="createValidCard" access="private" returntype="any">
		<!--- these values simulate a valid card with matching avs/cvv --->
		<cfset var account = variables.cfpaymentCore.createCreditCard() />
		<cfset account.setAccount(4940702861332472) />
		<cfset account.setMonth(05) />
		<cfset account.setYear(2019) />
		<cfset account.setVerificationValue(999) />
		<cfset account.setFirstName("John") />
		<cfset account.setLastName("Doe") />
		<cfset account.setAddress("888") />
		<cfset account.setPostalCode("77777") />

		<cfreturn account />
	</cffunction>

	<cffunction name="createInvalidCard" access="private" returntype="any">
		<!--- these values simulate a valid card with matching avs/cvv --->
		<cfset var account = variables.cfpaymentCore.createCreditCard() />
		<cfset account.setAccount(4100000000000000) />
		<cfset account.setMonth(10) />
		<cfset account.setYear(2010) />
		<cfset account.setVerificationValue(123) />
		<cfset account.setFirstName("John") />
		<cfset account.setLastName("Doe") />
		<cfset account.setAddress("236 N. Santa Cruz") />
		<cfset account.setPostalCode("95030") />

		<cfreturn account />
	</cffunction>

	<cffunction name="createValidCardWithoutCVV" access="private" returntype="any">
		<!--- these values simulate a valid card with matching avs/cvv --->
		<cfset var account = variables.cfpaymentCore.createCreditCard() />
		<cfset account.setAccount(4111111111111111) />
		<cfset account.setMonth(10) />
		<cfset account.setYear(2010) />
		<cfset account.setVerificationValue() />
		<cfset account.setFirstName("John") />
		<cfset account.setLastName("Doe") />
		<cfset account.setAddress("888") />
		<cfset account.setPostalCode("77777") />

		<cfreturn account />
	</cffunction>

	<cffunction name="createValidCardWithBadCVV" access="private" returntype="any">
		<!--- these values simulate a valid card with matching avs/cvv --->
		<cfset var account = variables.cfpaymentCore.createCreditCard() />
		<cfset account.setAccount(4111111111111111) />
		<cfset account.setMonth(10) />
		<cfset account.setYear(2010) />
		<cfset account.setVerificationValue(111) />
		<cfset account.setFirstName("John") />
		<cfset account.setLastName("Doe") />
		<cfset account.setAddress("888") />
		<cfset account.setPostalCode("77777") />

		<cfreturn account />
	</cffunction>

	<cffunction name="createValidCardWithoutStreetMatch" access="private" returntype="any">
		<!--- these values simulate a valid card with matching avs/cvv --->
		<cfset var account = variables.cfpaymentCore.createCreditCard() />
		<cfset account.setAccount(4111111111111111) />
		<cfset account.setMonth(10) />
		<cfset account.setYear(2010) />
		<cfset account.setVerificationValue() />
		<cfset account.setFirstName("John") />
		<cfset account.setLastName("Doe") />
		<cfset account.setAddress("236 N. Santa Cruz") />
		<cfset account.setPostalCode("77777") />

		<cfreturn account />
	</cffunction>

	<cffunction name="createValidCardWithoutZipMatch" access="private" returntype="any">
		<!--- these values simulate a valid card with matching avs/cvv --->
		<cfset var account = variables.cfpaymentCore.createCreditCard() />
		<cfset account.setAccount(4111111111111111) />
		<cfset account.setMonth(10) />
		<cfset account.setYear(2010) />
		<cfset account.setVerificationValue() />
		<cfset account.setFirstName("John") />
		<cfset account.setLastName("Doe") />
		<cfset account.setAddress("888") />
		<cfset account.setPostalCode("95030") />

		<cfreturn account />
	</cffunction>


</cfcomponent>
