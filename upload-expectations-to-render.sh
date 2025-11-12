#!/bin/bash

# ============================================================================
# Upload MockServer Expectations to Render.com
# ============================================================================
# This script uploads expectations to running MockServer via REST API
# ============================================================================

MOCKSERVER_URL="https://mockdataapi-28lv.onrender.com"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "============================================================================"
echo "  Uploading MockServer Expectations to Render.com"
echo "============================================================================"
echo -e "${YELLOW}Target: $MOCKSERVER_URL${NC}"
echo ""

# ============================================================================
# Expectation 1: GetStatus
# ============================================================================
echo -e "${YELLOW}[1/2] Uploading GetStatus expectation...${NC}"

curl -s -X PUT "$MOCKSERVER_URL/mockserver/expectation" \
  -H "Content-Type: application/json" \
  -d '{
  "httpRequest": {
    "method": "POST",
    "path": "/nordex/services/nordex_opc",
    "body": {
      "type": "STRING",
      "string": ".*GetStatus.*"
    }
  },
  "httpResponse": {
    "statusCode": 200,
    "headers": {
      "Content-Type": ["text/xml; charset=utf-8"],
      "SOAPAction": ["http://opcfoundation.org/webservices/XMLDA/1.0/GetStatus"]
    },
    "body": "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n  <soap:Body>\n    <GetStatusResponse xmlns=\"http://opcfoundation.org/webservices/XMLDA/1.0/\">\n      <GetStatusResult>\n        <StatusInfo>Server is open for communication</StatusInfo>\n        <VendorInfo>Nordex Energy GmbH - MockServer</VendorInfo>\n        <ProductVersion>3.1.2-mock</ProductVersion>\n        <ServerState>running</ServerState>\n        <StartTime>2025-01-01T00:00:00Z</StartTime>\n        <CurrentTime>2025-11-12T12:00:00Z</CurrentTime>\n      </GetStatusResult>\n    </GetStatusResponse>\n  </soap:Body>\n</soap:Envelope>"
  },
  "priority": 1
}' > /dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ GetStatus expectation uploaded${NC}"
else
    echo -e "${RED}✗ Failed to upload GetStatus expectation${NC}"
fi
echo ""

# ============================================================================
# Expectation 2: Read with JavaScript Template
# ============================================================================
echo -e "${YELLOW}[2/2] Uploading Read expectation with dynamic data...${NC}"

# JavaScript template için escape edilmiş JSON
READ_TEMPLATE=$(cat << 'EOF'
function generateResponse() {
  const requestBody = request.body ? request.body.string : '';
  const itemNameRegex = /<ItemName>([^<]+)<\/ItemName>/g;
  const itemNames = [];
  let match;

  while ((match = itemNameRegex.exec(requestBody)) !== null) {
    itemNames.push(match[1]);
  }

  function randomValue(min, max, decimals) {
    const value = min + Math.random() * (max - min);
    return decimals !== undefined ? value.toFixed(decimals) : Math.floor(value);
  }

  function getTurError() {
    const rand = Math.random();
    if (rand < 0.85) return 'FM0';
    if (rand < 0.90) return 'FM103';
    if (rand < 0.95) return 'FM6';
    if (rand < 0.98) return 'FM105';
    return 'FM201';
  }

  function getParameterValue(paramName) {
    const windSpeed = randomValue(0, 25, 1);
    let power = 0;
    if (windSpeed >= 3 && windSpeed < 12) {
      power = randomValue(0, 2000, 1);
    } else if (windSpeed >= 12 && windSpeed < 25) {
      power = randomValue(1900, 2000, 1);
    }

    const paramValues = {
      'PwrAct': power,
      'WSpd': windSpeed,
      'WDir': randomValue(0, 360, 0),
      'NacDir': randomValue(0, 360, 0),
      'RotSpd': windSpeed > 3 ? randomValue(8, 20, 1) : '0.0',
      'GnSpd': windSpeed > 3 ? randomValue(1200, 1800, 0) : 0,
      'TurError': getTurError(),
      'GriVolt1': randomValue(655, 725, 1),
      'GriVolt2': randomValue(655, 725, 1),
      'GriVolt3': randomValue(655, 725, 1),
      'GriCurL1': power > 0 ? randomValue(1400, 1600, 1) : '0.0',
      'GriCurL2': power > 0 ? randomValue(1400, 1600, 1) : '0.0',
      'GriCurL3': power > 0 ? randomValue(1400, 1600, 1) : '0.0',
      'GnBrgBS': randomValue(35, 60, 1),
      'GnBrgAS': randomValue(35, 60, 1),
      'GnTmpL1': randomValue(45, 75, 1),
      'GnTmpL2': randomValue(45, 75, 1),
      'GnTmpInlet': randomValue(10, 25, 1),
      'GnTmpOutlet': randomValue(35, 55, 1),
      'AirPres': randomValue(1000, 1030, 2),
      'ExtTmp': randomValue(-10, 35, 1),
      'COUNT20': randomValue(10000000, 99999999, 0),
      'COUNT21': randomValue(10000000, 99999999, 0)
    };

    return paramValues[paramName] || randomValue(0, 100, 1);
  }

  const timestamp = new Date().toISOString();
  let itemsXml = '';

  itemNames.forEach(function(itemName) {
    const parts = itemName.split('/');
    const paramName = parts.length > 2 ? parts[2] : 'Unknown';
    const value = getParameterValue(paramName);

    itemsXml += '            <Items>\n';
    itemsXml += '              <ItemName>' + itemName + '</ItemName>\n';
    itemsXml += '              <Value>' + value + '</Value>\n';
    itemsXml += '              <Quality>\n';
    itemsXml += '                <QualityField>14</QualityField>\n';
    itemsXml += '                <LimitField>0</LimitField>\n';
    itemsXml += '                <VendorField>0</VendorField>\n';
    itemsXml += '              </Quality>\n';
    itemsXml += '              <Timestamp>' + timestamp + '</Timestamp>\n';
    itemsXml += '              <TimestampSpecified>true</TimestampSpecified>\n';
    itemsXml += '              <ResultID>\n';
    itemsXml += '                <Name>Success</Name>\n';
    itemsXml += '                <Namespace>http://opcfoundation.org/</Namespace>\n';
    itemsXml += '                <IsEmpty>false</IsEmpty>\n';
    itemsXml += '              </ResultID>\n';
    itemsXml += '            </Items>\n';
  });

  return {
    'statusCode': 200,
    'headers': {
      'Content-Type': ['text/xml; charset=utf-8'],
      'SOAPAction': ['http://opcfoundation.org/webservices/XMLDA/1.0/Read']
    },
    'body': '<?xml version="1.0" encoding="utf-8"?>\n' +
            '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">\n' +
            '  <soap:Body>\n' +
            '    <ReadResponse xmlns="http://opcfoundation.org/webservices/XMLDA/1.0/">\n' +
            '      <ReadResult>\n' +
            '        <ReplyItemList>\n' +
            '          <Items>\n' +
            itemsXml +
            '          </Items>\n' +
            '        </ReplyItemList>\n' +
            '      </ReadResult>\n' +
            '    </ReadResponse>\n' +
            '  </soap:Body>\n' +
            '</soap:Envelope>'
  };
}

return generateResponse();
EOF
)

curl -s -X PUT "$MOCKSERVER_URL/mockserver/expectation" \
  -H "Content-Type: application/json" \
  -d "{
  \"httpRequest\": {
    \"method\": \"POST\",
    \"path\": \"/nordex/services/nordex_opc\",
    \"body\": {
      \"type\": \"REGEX\",
      \"regex\": \".*<Read.*\"
    }
  },
  \"httpResponseTemplate\": {
    \"templateType\": \"JAVASCRIPT\",
    \"template\": $(echo "$READ_TEMPLATE" | jq -Rs .)
  },
  \"priority\": 2
}" > /dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Read expectation with dynamic template uploaded${NC}"
else
    echo -e "${RED}✗ Failed to upload Read expectation${NC}"
fi
echo ""

# ============================================================================
# Verify expectations
# ============================================================================
echo -e "${YELLOW}Verifying uploaded expectations...${NC}"
EXPECTATIONS_COUNT=$(curl -s "$MOCKSERVER_URL/mockserver/expectation" | jq 'length')

echo "Total expectations: $EXPECTATIONS_COUNT"
echo ""

# ============================================================================
# Test the expectations
# ============================================================================
echo -e "${YELLOW}Testing GetStatus...${NC}"
curl -s -X POST "$MOCKSERVER_URL/nordex/services/nordex_opc" \
  -H "Content-Type: text/xml" \
  -d '<?xml version="1.0"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetStatus xmlns="http://opcfoundation.org/webservices/XMLDA/1.0/">
      <LocaleID>en-us</LocaleID>
    </GetStatus>
  </soap:Body>
</soap:Envelope>' | grep -q "Server is open for communication"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ GetStatus working!${NC}"
else
    echo -e "${RED}✗ GetStatus not working${NC}"
fi
echo ""

echo "============================================================================"
echo -e "${GREEN}✓ Expectations uploaded successfully!${NC}"
echo "============================================================================"
echo ""
echo "Your MockServer is now ready at:"
echo -e "${YELLOW}$MOCKSERVER_URL${NC}"
echo ""
echo "Test with:"
echo "  curl -X POST $MOCKSERVER_URL/nordex/services/nordex_opc -H 'Content-Type: text/xml' -d '<soap:Envelope>...</soap:Envelope>'"
echo ""
