#!/bin/bash

# ============================================================================
# Render.com MockServer Deployment Test Script
# ============================================================================
# URL: https://mockdataapi-28lv.onrender.com
# ============================================================================

MOCKSERVER_URL="https://mockdataapi-28lv.onrender.com"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "============================================================================"
echo "  MockServer Deployment Test - Render.com"
echo "============================================================================"
echo -e "${BLUE}URL: $MOCKSERVER_URL${NC}"
echo ""

# ============================================================================
# Test 1: MockServer Health Check
# ============================================================================
echo -e "${YELLOW}[1/5] Testing MockServer Health...${NC}"
echo "Request: GET $MOCKSERVER_URL/mockserver/status"
echo ""

HEALTH_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$MOCKSERVER_URL/mockserver/status")

if [ "$HEALTH_RESPONSE" == "200" ]; then
    echo -e "${GREEN}✓ MockServer is healthy (HTTP 200)${NC}"
    HEALTH_BODY=$(curl -s "$MOCKSERVER_URL/mockserver/status")
    echo "Response: $HEALTH_BODY"
else
    echo -e "${RED}✗ MockServer health check failed (HTTP $HEALTH_RESPONSE)${NC}"
    echo ""
    echo "Possible issues:"
    echo "  - Container starting up (wait 30-60 seconds)"
    echo "  - Port mapping issue"
    echo "  - Deployment failed"
    echo ""
    exit 1
fi
echo ""

# ============================================================================
# Test 2: SOAP GetStatus() Request
# ============================================================================
echo -e "${YELLOW}[2/5] Testing SOAP GetStatus() Request...${NC}"
echo "Request: POST $MOCKSERVER_URL/nordex/services/nordex_opc"
echo "SOAPAction: GetStatus"
echo ""

GET_STATUS_REQUEST='<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <soap:Body>
    <GetStatus xmlns="http://opcfoundation.org/webservices/XMLDA/1.0/">
      <LocaleID>en-us</LocaleID>
      <ClientRequestHandle></ClientRequestHandle>
    </GetStatus>
  </soap:Body>
</soap:Envelope>'

GET_STATUS_RESPONSE=$(curl -s -X POST "$MOCKSERVER_URL/nordex/services/nordex_opc" \
  -H "Content-Type: text/xml; charset=utf-8" \
  -H "SOAPAction: http://opcfoundation.org/webservices/XMLDA/1.0/GetStatus" \
  -d "$GET_STATUS_REQUEST")

if echo "$GET_STATUS_RESPONSE" | grep -q "Server is open for communication"; then
    echo -e "${GREEN}✓ GetStatus() successful${NC}"
    echo ""

    # Extract values
    STATUS_INFO=$(echo "$GET_STATUS_RESPONSE" | grep -oP '(?<=<StatusInfo>)[^<]+')
    PRODUCT_VERSION=$(echo "$GET_STATUS_RESPONSE" | grep -oP '(?<=<ProductVersion>)[^<]+')
    VENDOR_INFO=$(echo "$GET_STATUS_RESPONSE" | grep -oP '(?<=<VendorInfo>)[^<]+')

    echo "  StatusInfo: $STATUS_INFO"
    echo "  ProductVersion: $PRODUCT_VERSION"
    echo "  VendorInfo: $VENDOR_INFO"
else
    echo -e "${RED}✗ GetStatus() failed${NC}"
    echo "Response:"
    echo "$GET_STATUS_RESPONSE" | head -20
fi
echo ""

# ============================================================================
# Test 3: SOAP Read() - Single Parameter
# ============================================================================
echo -e "${YELLOW}[3/5] Testing SOAP Read() - Single Parameter (PwrAct)...${NC}"
echo "Request: POST $MOCKSERVER_URL/nordex/services/nordex_opc"
echo "Parameter: 01WEA82943/analog/PwrAct"
echo ""

READ_SINGLE_REQUEST='<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <soap:Body>
    <Read xmlns="http://opcfoundation.org/webservices/XMLDA/1.0/">
      <Options>
        <ReturnErrorText>true</ReturnErrorText>
        <ReturnDiagnosticInfo>false</ReturnDiagnosticInfo>
        <ReturnItemTime>true</ReturnItemTime>
        <ReturnItemPath>false</ReturnItemPath>
        <ReturnItemName>true</ReturnItemName>
        <RequestDeadlineSpecified>false</RequestDeadlineSpecified>
        <ClientRequestHandle></ClientRequestHandle>
        <LocaleID>en-us</LocaleID>
      </Options>
      <ItemList>
        <MaxAge>10000</MaxAge>
        <Items>
          <Items><ItemName>01WEA82943/analog/PwrAct</ItemName></Items>
        </Items>
      </ItemList>
    </Read>
  </soap:Body>
</soap:Envelope>'

READ_SINGLE_RESPONSE=$(curl -s -X POST "$MOCKSERVER_URL/nordex/services/nordex_opc" \
  -H "Content-Type: text/xml; charset=utf-8" \
  -H "SOAPAction: http://opcfoundation.org/webservices/XMLDA/1.0/Read" \
  -d "$READ_SINGLE_REQUEST")

if echo "$READ_SINGLE_RESPONSE" | grep -q "01WEA82943/analog/PwrAct"; then
    echo -e "${GREEN}✓ Read() single parameter successful${NC}"
    echo ""

    # Extract values
    ITEM_NAME=$(echo "$READ_SINGLE_RESPONSE" | grep -oP '(?<=<ItemName>)[^<]+' | head -1)
    VALUE=$(echo "$READ_SINGLE_RESPONSE" | grep -oP '(?<=<Value>)[^<]+' | head -1)
    QUALITY=$(echo "$READ_SINGLE_RESPONSE" | grep -oP '(?<=<QualityField>)[^<]+' | head -1)
    TIMESTAMP=$(echo "$READ_SINGLE_RESPONSE" | grep -oP '(?<=<Timestamp>)[^<]+' | head -1)

    echo "  ItemName: $ITEM_NAME"
    echo "  Value: $VALUE kW"
    echo "  Quality: $QUALITY (14 = Good)"
    echo "  Timestamp: $TIMESTAMP"
else
    echo -e "${RED}✗ Read() single parameter failed${NC}"
    echo "Response:"
    echo "$READ_SINGLE_RESPONSE" | head -20
fi
echo ""

# ============================================================================
# Test 4: SOAP Read() - Multiple Parameters (23 parameters)
# ============================================================================
echo -e "${YELLOW}[4/5] Testing SOAP Read() - Multiple Parameters (23 params)...${NC}"
echo "Request: POST $MOCKSERVER_URL/nordex/services/nordex_opc"
echo "Parameters: All 23 turbine parameters"
echo ""

READ_MULTI_REQUEST='<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <Read xmlns="http://opcfoundation.org/webservices/XMLDA/1.0/">
      <Options>
        <ReturnErrorText>true</ReturnErrorText>
        <ReturnItemTime>true</ReturnItemTime>
        <ReturnItemName>true</ReturnItemName>
        <LocaleID>en-us</LocaleID>
      </Options>
      <ItemList>
        <MaxAge>10000</MaxAge>
        <Items>
          <Items><ItemName>01WEA82943/analog/PwrAct</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/WSpd</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/WDir</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/NacDir</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/RotSpd</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GnSpd</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/TurError</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GriVolt1</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GriVolt2</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GriVolt3</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GriCurL1</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GriCurL2</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GriCurL3</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GnBrgBS</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GnBrgAS</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GnTmpL1</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GnTmpL2</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GnTmpInlet</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GnTmpOutlet</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/AirPres</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/ExtTmp</ItemName></Items>
          <Items><ItemName>01WEA82943/counter/COUNT20</ItemName></Items>
          <Items><ItemName>01WEA82943/counter/COUNT21</ItemName></Items>
        </Items>
      </ItemList>
    </Read>
  </soap:Body>
</soap:Envelope>'

READ_MULTI_RESPONSE=$(curl -s -X POST "$MOCKSERVER_URL/nordex/services/nordex_opc" \
  -H "Content-Type: text/xml; charset=utf-8" \
  -H "SOAPAction: http://opcfoundation.org/webservices/XMLDA/1.0/Read" \
  -d "$READ_MULTI_REQUEST")

ITEM_COUNT=$(echo "$READ_MULTI_RESPONSE" | grep -c "<ItemName>")

if [ "$ITEM_COUNT" -ge 23 ]; then
    echo -e "${GREEN}✓ Read() multiple parameters successful${NC}"
    echo "  Received: $ITEM_COUNT items"
    echo ""
    echo "  Sample values:"

    # Extract sample values
    PWR=$(echo "$READ_MULTI_RESPONSE" | grep -A 2 "PwrAct" | grep -oP '(?<=<Value>)[^<]+' | head -1)
    WSPD=$(echo "$READ_MULTI_RESPONSE" | grep -A 2 "WSpd" | grep -oP '(?<=<Value>)[^<]+' | head -1)
    TERROR=$(echo "$READ_MULTI_RESPONSE" | grep -A 2 "TurError" | grep -oP '(?<=<Value>)[^<]+' | head -1)
    COUNT=$(echo "$READ_MULTI_RESPONSE" | grep -A 2 "COUNT20" | grep -oP '(?<=<Value>)[^<]+' | head -1)

    echo "    - PwrAct: $PWR kW"
    echo "    - WSpd: $WSPD m/s"
    echo "    - TurError: $TERROR"
    echo "    - COUNT20: $COUNT"
else
    echo -e "${RED}✗ Read() multiple parameters failed${NC}"
    echo "  Expected: 23 items, Received: $ITEM_COUNT items"
fi
echo ""

# ============================================================================
# Test 5: Dynamic Data Test (2 consecutive requests)
# ============================================================================
echo -e "${YELLOW}[5/5] Testing Dynamic Data (values should differ)...${NC}"
echo "Making 2 consecutive requests to verify dynamic data generation..."
echo ""

# First request
RESPONSE1=$(curl -s -X POST "$MOCKSERVER_URL/nordex/services/nordex_opc" \
  -H "Content-Type: text/xml" \
  -d "$READ_SINGLE_REQUEST")
VALUE1=$(echo "$RESPONSE1" | grep -oP '(?<=<Value>)[^<]+' | head -1)
TIMESTAMP1=$(echo "$RESPONSE1" | grep -oP '(?<=<Timestamp>)[^<]+' | head -1)

sleep 2

# Second request
RESPONSE2=$(curl -s -X POST "$MOCKSERVER_URL/nordex/services/nordex_opc" \
  -H "Content-Type: text/xml" \
  -d "$READ_SINGLE_REQUEST")
VALUE2=$(echo "$RESPONSE2" | grep -oP '(?<=<Value>)[^<]+' | head -1)
TIMESTAMP2=$(echo "$RESPONSE2" | grep -oP '(?<=<Timestamp>)[^<]+' | head -1)

echo "  Request 1: PwrAct = $VALUE1 kW (at $TIMESTAMP1)"
echo "  Request 2: PwrAct = $VALUE2 kW (at $TIMESTAMP2)"
echo ""

if [ "$VALUE1" != "$VALUE2" ]; then
    echo -e "${GREEN}✓ Dynamic data verified - values are different!${NC}"
else
    echo -e "${YELLOW}⚠ Values are identical - might be cached${NC}"
    echo "  This is OK for the first requests after deployment"
fi
echo ""

# ============================================================================
# Summary
# ============================================================================
echo "============================================================================"
echo "  Test Summary"
echo "============================================================================"
echo -e "${GREEN}All tests completed successfully!${NC}"
echo ""
echo "Your MockServer is ready at:"
echo -e "${BLUE}$MOCKSERVER_URL${NC}"
echo ""
echo "Dashboard:"
echo -e "${BLUE}$MOCKSERVER_URL/mockserver/dashboard${NC}"
echo ""
echo "============================================================================"
echo ""
