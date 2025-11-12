/**
 * Dynamic Turbine Data Generator for MockServer
 * Generates realistic turbine telemetry data with random variations
 */

function generateTurbineData(turbineId) {
    const now = new Date().toISOString();

    // Wind speed between 0-25 m/s (realistic range)
    const windSpeed = (Math.random() * 25).toFixed(1);

    // Power calculation based on wind speed (cubic relationship)
    // Rated power: 2000 kW, cut-in: 3 m/s, rated wind: 12 m/s, cut-out: 25 m/s
    let power = 0;
    if (windSpeed >= 3 && windSpeed < 12) {
        // Power increases cubically from cut-in to rated
        power = (2000 * Math.pow((windSpeed - 3) / 9, 3)).toFixed(1);
    } else if (windSpeed >= 12 && windSpeed < 25) {
        // Rated power region with small variations
        power = (1900 + Math.random() * 100).toFixed(1);
    } else {
        power = 0; // Below cut-in or above cut-out
    }

    // Wind direction (0-360 degrees)
    const windDirection = Math.floor(Math.random() * 360);

    // Nacelle direction (follows wind with small lag)
    const nacelleDirection = (windDirection + Math.floor(Math.random() * 20 - 10) + 360) % 360;

    // Rotor speed (0-20 RPM)
    const rotorSpeed = windSpeed > 3 ? (8 + Math.random() * 12).toFixed(1) : "0.0";

    // Generator speed (1200-1800 RPM when running)
    const generatorSpeed = windSpeed > 3 ? Math.floor(1200 + Math.random() * 600) : 0;

    // TurError status based on conditions
    let turError = "FM0"; // Normal operation
    if (windSpeed < 3) {
        turError = "FM103"; // Low wind
    } else if (windSpeed > 24) {
        turError = "FM105"; // High wind
    } else if (Math.random() < 0.05) {
        // 5% chance of random errors
        const errors = ["FM201", "FM6", "FM103", "FM105"];
        turError = errors[Math.floor(Math.random() * errors.length)];
    }

    // Grid voltages (690V ± 5%)
    const gridVolt1 = (690 + (Math.random() * 70 - 35)).toFixed(1);
    const gridVolt2 = (690 + (Math.random() * 70 - 35)).toFixed(1);
    const gridVolt3 = (690 + (Math.random() * 70 - 35)).toFixed(1);

    // Grid currents (based on power and voltage)
    const avgVoltage = (parseFloat(gridVolt1) + parseFloat(gridVolt2) + parseFloat(gridVolt3)) / 3;
    const avgCurrent = power > 0 ? ((parseFloat(power) * 1000) / (Math.sqrt(3) * avgVoltage)).toFixed(1) : "0.0";
    const gridCurL1 = (parseFloat(avgCurrent) * (0.95 + Math.random() * 0.1)).toFixed(1);
    const gridCurL2 = (parseFloat(avgCurrent) * (0.95 + Math.random() * 0.1)).toFixed(1);
    const gridCurL3 = (parseFloat(avgCurrent) * (0.95 + Math.random() * 0.1)).toFixed(1);

    // Generator bearing temperatures (35-60°C)
    const gnBrgBS = (35 + Math.random() * 25).toFixed(1);
    const gnBrgAS = (35 + Math.random() * 25).toFixed(1);

    // Generator winding temperatures (45-75°C)
    const gnTmpL1 = (45 + Math.random() * 30).toFixed(1);
    const gnTmpL2 = (45 + Math.random() * 30).toFixed(1);

    // Cooling temperatures
    const gnTmpInlet = (10 + Math.random() * 15).toFixed(1);
    const gnTmpOutlet = (35 + Math.random() * 20).toFixed(1);

    // Air pressure (1000-1030 hPa)
    const airPres = (1000 + Math.random() * 30).toFixed(2);

    // External temperature (-10 to 35°C)
    const extTmp = (-10 + Math.random() * 45).toFixed(1);

    // Production counters (cumulative, incrementing)
    const baseCounter = Math.floor(Math.random() * 50000000) + 10000000;
    const count20 = baseCounter + Math.floor(parseFloat(power) * 10);
    const count21 = count20; // Secondary counter matches primary

    return {
        turbineId: turbineId,
        timestamp: now,
        PwrAct: power,
        WSpd: windSpeed,
        WDir: windDirection,
        NacDir: nacelleDirection,
        RotSpd: rotorSpeed,
        GnSpd: generatorSpeed,
        TurError: turError,
        GriVolt1: gridVolt1,
        GriVolt2: gridVolt2,
        GriVolt3: gridVolt3,
        GriCurL1: gridCurL1,
        GriCurL2: gridCurL2,
        GriCurL3: gridCurL3,
        GnBrgBS: gnBrgBS,
        GnBrgAS: gnBrgAS,
        GnTmpL1: gnTmpL1,
        GnTmpL2: gnTmpL2,
        GnTmpInlet: gnTmpInlet,
        GnTmpOutlet: gnTmpOutlet,
        AirPres: airPres,
        ExtTmp: extTmp,
        COUNT20: count20,
        COUNT21: count21
    };
}

// Export for use in MockServer
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { generateTurbineData };
}
