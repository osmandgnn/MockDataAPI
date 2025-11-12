#!/bin/bash

# ============================================================================
# MockServer SOAP Test Script
# ============================================================================
# This script tests the MockServer SOAP endpoints to verify they're working
# ============================================================================

MOCKSERVER_URL="http://localhost:1080/nordex/services/nordex_opc"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "============================================================================"
echo "MockServer SOAP Endpoint Test"
echo "============================================================================"
echo ""

# Test 1: MockServer Health Check
echo -e "${YELLOW}[1/4] Testing MockServer health...${NC}"
HEALTH_CHECK=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:1080/mockserver/status)
if [ "$HEALTH_CHECK" == "200" ]; then
    echo -e "${GREEN}✓ MockServer is running${NC}"
else
    echo -e "${RED}✗ MockServer is not responding (HTTP $HEALTH_CHECK)${NC}"
    exit 1
fi
echo ""

# Test 2: GetStatus SOAP Request
echo -e "${YELLOW}[2/4] Testing GetStatus() SOAP request...${NC}"
GET_STATUS_REQUEST='<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <soap:Body>
    <GetStatus xmlns="http://opcfoundation.org/webservices/XMLDA/1.0/">
      <LocaleID>en-us</LocaleID>
      <ClientRequestHandle></ClientRequestHandle>
    </GetStatus>
  </soap:Body>
</soap:Envelope>'

GET_STATUS_RESPONSE=$(curl -s -X POST "$MOCKSERVER_URL" \
  -H "Content-Type: text/xml; charset=utf-8" \
  -H "SOAPAction: http://opcfoundation.org/webservices/XMLDA/1.0/GetStatus" \
  -d "$GET_STATUS_REQUEST")

if echo "$GET_STATUS_RESPONSE" | grep -q "Server is open for communication"; then
    echo -e "${GREEN}✓ GetStatus() request successful${NC}"
    echo "  Response contains: Server is open for communication"

    # Extract ProductVersion
    PRODUCT_VERSION=$(echo "$GET_STATUS_RESPONSE" | grep -oP '(?<=<ProductVersion>)[^<]+')
    echo "  Product Version: $PRODUCT_VERSION"
else
    echo -e "${RED}✗ GetStatus() request failed${NC}"
    echo "Response: $GET_STATUS_RESPONSE"
fi
echo ""

# Test 3: Read SOAP Request (Single Parameter)
echo -e "${YELLOW}[3/4] Testing Read() SOAP request (single parameter)...${NC}"
READ_REQUEST_SINGLE='<?xml version="1.0" encoding="utf-8"?>
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

READ_RESPONSE_SINGLE=$(curl -s -X POST "$MOCKSERVER_URL" \
  -H "Content-Type: text/xml; charset=utf-8" \
  -H "SOAPAction: http://opcfoundation.org/webservices/XMLDA/1.0/Read" \
  -d "$READ_REQUEST_SINGLE")

if echo "$READ_RESPONSE_SINGLE" | grep -q "01WEA82943/analog/PwrAct"; then
    echo -e "${GREEN}✓ Read() single parameter request successful${NC}"

    # Extract value
    POWER_VALUE=$(echo "$READ_RESPONSE_SINGLE" | grep -oP '(?<=<Value>)[^<]+' | head -1)
    QUALITY=$(echo "$READ_RESPONSE_SINGLE" | grep -oP '(?<=<QualityField>)[^<]+' | head -1)
    TIMESTAMP=$(echo "$READ_RESPONSE_SINGLE" | grep -oP '(?<=<Timestamp>)[^<]+' | head -1)

    echo "  ItemName: 01WEA82943/analog/PwrAct"
    echo "  Value: $POWER_VALUE kW"
    echo "  Quality: $QUALITY (14 = Good)"
    echo "  Timestamp: $TIMESTAMP"
else
    echo -e "${RED}✗ Read() single parameter request failed${NC}"
    echo "Response: $READ_RESPONSE_SINGLE"
fi
echo ""

# Test 4: Read SOAP Request (Multiple Parameters)
echo -e "${YELLOW}[4/4] Testing Read() SOAP request (multiple parameters)...${NC}"
READ_REQUEST_MULTI='<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
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
          <Items><ItemName>01WEA82943/analog/TurError</ItemName></Items>
          <Items><ItemName>01WEA82943/counter/COUNT20</ItemName></Items>
        </Items>
      </ItemList>
    </Read>
  </soap:Body>
</soap:Envelope>'

READ_RESPONSE_MULTI=$(curl -s -X POST "$MOCKSERVER_URL" \
  -H "Content-Type: text/xml; charset=utf-8" \
  -H "SOAPAction: http://opcfoundation.org/webservices/XMLDA/1.0/Read" \
  -d "$READ_REQUEST_MULTI")

ITEM_COUNT=$(echo "$READ_RESPONSE_MULTI" | grep -c "<ItemName>")

if [ "$ITEM_COUNT" -ge 4 ]; then
    echo -e "${GREEN}✓ Read() multiple parameters request successful${NC}"
    echo "  Received $ITEM_COUNT items"

    # Extract all values
    echo ""
    echo "  Sample values:"
    echo "$READ_RESPONSE_MULTI" | grep -A 2 "<ItemName>" | while read line; do
        if echo "$line" | grep -q "<ItemName>"; then
            ITEM_NAME=$(echo "$line" | grep -oP '(?<=<ItemName>)[^<]+')
            read VALUE_LINE
            VALUE=$(echo "$VALUE_LINE" | grep -oP '(?<=<Value>)[^<]+')
            echo "    - $ITEM_NAME = $VALUE"
        fi
    done
else
    echo -e "${RED}✗ Read() multiple parameters request failed${NC}"
    echo "Expected 4+ items, received $ITEM_COUNT"
fi
echo ""

# Summary
echo "============================================================================"
echo -e "${GREEN}All tests completed!${NC}"
echo "============================================================================"
echo ""
echo "Next steps:"
echo "1. Update your database OPC endpoints:"
echo "   docker exec -i energy-portal-postgres psql -U energy_user -d energy_portal < mockserver/scripts/update-opc-endpoints-to-mockserver.sql"
echo ""
echo "2. Restart your backend service to pick up the new endpoints"
echo ""
echo "3. Monitor OPC polling logs:"
echo "   docker logs -f energy-portal-backend | grep OPC"
echo ""
echo "4. View MockServer requests:"
echo "   http://localhost:1080/mockserver/dashboard"
