#!/usr/bin/env python3
"""Builds the Rogue OBD2 generic fault-code pack (app/assets/dtc/rogue_generic.json).

All text here is original wording written for this project. It describes the
generally accepted meaning of SAE-defined generic codes; it is not copied from
SAE J2012 or any third-party list. Only codes whose generic meaning is well
established are included. Anything not in this pack is shown as unknown.

Run: python3 tool/build_dtc_pack.py
"""
import json, os, sys

PACK = {
    "id": "rogue-generic",
    "title": "Rogue generic fault-code descriptions",
    "version": "1.0.0",
    "source": "Original descriptions written for Rogue OBD2 Diagnostic Tool. Generic interpretations; manufacturers may define codes differently.",
    "scope": "generic",
}

CODES = {}

def add(code, description, category, severity, causes, symptoms, inspection, repairs, components):
    code = code.upper()
    assert code not in CODES, f"duplicate {code}"
    assert severity in ("critical", "high", "medium", "low", "informational"), code
    for name, lst in (("causes", causes), ("symptoms", symptoms), ("inspection", inspection), ("repairs", repairs), ("components", components)):
        assert lst, f"{code} has empty {name}"
    CODES[code] = {
        "code": code, "description": description, "category": category, "severity": severity,
        "causes": causes, "symptoms": symptoms, "inspection": inspection, "repairs": repairs,
        "components": components, "confidence": "generic",
    }

# ---------------------------------------------------------------- helpers
def bank_of(sensor_bank):  # text helper
    return f"bank {sensor_bank}"

CIRCUIT_INSPECT = [
    "Inspect the connector for corrosion, bent pins and poor locking",
    "Check the wiring harness for chafing, heat damage or rodent damage",
    "With a multimeter, check supply voltage, ground and signal at the sensor connector against the service manual values",
    "Clear the code and confirm whether it returns",
]

def circuit_family(code, part, kind, comp, category, severity="medium", symptoms=None, extra_causes=None):
    """kind: 'circuit' | 'low' | 'high' | 'range' | 'intermittent'."""
    desc = {
        "circuit": f"{part}: circuit fault",
        "low": f"{part}: signal voltage too low",
        "high": f"{part}: signal voltage too high",
        "range": f"{part}: reading out of expected range or implausible",
        "intermittent": f"{part}: signal intermittent or erratic",
    }[kind]
    causes = {
        "circuit": [f"Open or shorted wiring to the {comp}", f"Faulty {comp}", "Poor connector contact"],
        "low": [f"Signal wire shorted to ground", f"Faulty {comp}", "Open reference (5 V) supply", "Corroded connector"],
        "high": [f"Signal wire open or shorted to voltage", f"Faulty {comp}", "Open sensor ground", "Corroded connector"],
        "range": [f"{comp[0].upper() + comp[1:]} reading does not match related sensors", f"Ageing or contaminated {comp}", "High resistance in wiring or connector"],
        "intermittent": ["Loose connector or broken wire strand", f"Faulty {comp}", "Wiring rubbing against engine parts"],
    }[kind] + (extra_causes or [])
    add(code, desc, category, severity, causes,
        symptoms or ["Check engine light on", "Possible poor running or reduced performance"],
        CIRCUIT_INSPECT if kind != "range" else [
            f"Compare the {comp} reading in Live Data with related sensors",
            "Inspect wiring and connector for damage or corrosion",
            f"Check the {comp} against the specification in the service manual",
        ],
        ["Repair damaged wiring or connector", f"Replace the {comp} if it fails testing"],
        [comp])

# ---------------------------------------------------------------- camshaft timing
for code, bank, cam, kind in [
    ("P0010", 1, "intake", "circuit"), ("P0011", 1, "intake", "advanced"), ("P0012", 1, "intake", "retarded"),
    ("P0013", 1, "exhaust", "circuit"), ("P0014", 1, "exhaust", "advanced"),
    ("P0020", 2, "intake", "circuit"), ("P0021", 2, "intake", "advanced"),
]:
    if kind == "circuit":
        add(code, f"Camshaft timing actuator ({cam}, bank {bank}): control circuit fault", "Variable valve timing", "medium",
            ["Faulty variable valve timing solenoid", "Open or shorted solenoid wiring", "Connector fault"],
            ["Check engine light on", "Rough idle", "Reduced power or poor economy"],
            ["Check solenoid resistance against specification", "Inspect wiring and connector", "Command the solenoid with a scan tool if supported and listen for a click"],
            ["Repair wiring", "Replace the timing actuator solenoid"],
            [f"{cam} camshaft timing solenoid", "Engine control module"])
    else:
        word = "too far advanced" if kind == "advanced" else "too far retarded"
        add(code, f"Camshaft timing ({cam}, bank {bank}): {word} or system performance fault", "Variable valve timing", "medium",
            ["Low or dirty engine oil", "Sticking timing solenoid or blocked oil screen", "Worn timing chain or stretched chain", "Faulty cam phaser"],
            ["Check engine light on", "Rough idle or stalling", "Rattle on start-up", "Reduced power"],
            ["Check oil level, grade and condition first", "Inspect the timing solenoid and its oil screen", "Compare desired and actual cam angle in Live Data if available", "Check timing chain stretch (crank/cam correlation)"],
            ["Change oil to the correct grade", "Clean or replace the timing solenoid", "Replace the timing chain or cam phaser if worn"],
            [f"{cam} cam phaser", "Timing solenoid", "Timing chain", "Engine oil"])

for code, bank, sensor in [("P0016", 1, "A"), ("P0017", 1, "B"), ("P0018", 2, "A")]:
    add(code, f"Crankshaft and camshaft position do not agree (bank {bank}, cam sensor {sensor})", "Engine timing", "high",
        ["Stretched timing chain or jumped timing belt", "Faulty cam or crank sensor", "Cam phaser stuck", "Damaged reluctor ring"],
        ["Check engine light on", "Hard starting or no start", "Rough running", "Rattle from timing area"],
        ["Check timing chain/belt condition and alignment marks", "Inspect cam and crank sensors and wiring", "Check oil level and condition"],
        ["Replace timing chain/belt kit if stretched or out of time", "Replace faulty sensor"],
        ["Timing chain or belt", "Camshaft position sensor", "Crankshaft position sensor", "Cam phaser"])

# ---------------------------------------------------------------- O2 heater circuits
for code, bank, s, kind in [
    ("P0030", 1, 1, "circuit"), ("P0031", 1, 1, "low"), ("P0032", 1, 1, "high"),
    ("P0036", 1, 2, "circuit"), ("P0037", 1, 2, "low"), ("P0038", 1, 2, "high"),
    ("P0050", 2, 1, "circuit"), ("P0051", 2, 1, "low"), ("P0052", 2, 1, "high"),
    ("P0056", 2, 2, "circuit"), ("P0057", 2, 2, "low"), ("P0058", 2, 2, "high"),
]:
    word = {"circuit": "control circuit fault", "low": "control circuit low", "high": "control circuit high"}[kind]
    add(code, f"Oxygen sensor heater (bank {bank}, sensor {s}): {word}", "Oxygen sensors", "low",
        ["Failed heater element inside the oxygen sensor", "Blown fuse for the heater supply", "Damaged wiring near the exhaust", "Corroded connector"],
        ["Check engine light on", "Longer time to reach closed-loop fuel control", "Possible slight increase in fuel use"],
        ["Check the heater fuse", "Measure heater resistance at the sensor (typically a few ohms; see service manual)", "Check for battery voltage on the heater supply with ignition on", "Inspect wiring near the exhaust for melting"],
        ["Replace the oxygen sensor if the heater is open", "Repair wiring or replace fuse"],
        [f"Oxygen sensor bank {bank} sensor {s}", "Heater fuse/relay"])

# ---------------------------------------------------------------- air & fuel sensors
add("P0068", "Manifold pressure / mass air flow does not agree with throttle position", "Air induction", "medium",
    ["Vacuum or intake air leak after the MAF sensor", "Dirty or faulty MAF sensor", "Faulty MAP sensor", "Sticking throttle body"],
    ["Check engine light on", "Rough idle", "Hesitation"],
    ["Check for intake leaks (smoke test)", "Compare MAF, MAP and throttle readings in Live Data", "Inspect throttle body for carbon build-up"],
    ["Repair leaks", "Clean throttle body", "Replace faulty sensor"],
    ["Mass air flow sensor", "MAP sensor", "Throttle body", "Intake ducting"])
add("P0087", "Fuel rail or system pressure too low", "Fuel system", "high",
    ["Weak or failing fuel pump", "Clogged fuel filter", "Faulty pressure regulator", "Restricted fuel line", "Faulty fuel rail pressure sensor", "On diesels: air in fuel or worn high-pressure pump"],
    ["Hesitation or loss of power under load", "Hard starting", "Engine may stall", "Limp mode"],
    ["Compare desired and actual rail pressure in Live Data", "Check fuel filter service history", "Test fuel pump supply pressure and volume with a gauge", "Check pump power and ground"],
    ["Replace fuel filter", "Replace fuel pump or high-pressure pump", "Repair restriction or replace regulator"],
    ["Fuel pump", "Fuel filter", "Fuel pressure regulator", "Fuel rail pressure sensor"])
add("P0088", "Fuel rail or system pressure too high", "Fuel system", "high",
    ["Faulty fuel pressure regulator or control valve", "Faulty fuel rail pressure sensor", "Blocked fuel return (where fitted)"],
    ["Rough running", "Possible stalling", "Limp mode"],
    ["Compare desired and actual rail pressure", "Check the pressure sensor signal against a mechanical gauge", "Inspect the pressure control valve and its wiring"],
    ["Replace pressure regulator or control valve", "Replace rail pressure sensor"],
    ["Fuel pressure regulator", "Fuel rail pressure sensor"])
add("P0093", "Fuel system leak detected: large leak", "Fuel system", "critical",
    ["External fuel leak from lines, injector seals or rail", "Injector stuck open (diesel)", "Faulty pressure sensor giving false reading"],
    ["Strong fuel smell", "Visible fuel leak", "Loss of power or stalling"],
    ["Stop the engine and check for fuel leaks before running it again", "Inspect high-pressure lines and fittings", "Check injector leak-off where applicable"],
    ["Repair the leak before driving", "Replace leaking injector or line"],
    ["High-pressure fuel lines", "Fuel injectors", "Fuel rail"])

for code, kind in [("P0100", "circuit"), ("P0102", "low"), ("P0103", "high")]:
    circuit_family(code, "Mass air flow (MAF) sensor", kind, "mass air flow sensor", "Air induction",
                   symptoms=["Check engine light on", "Hesitation or stalling", "Poor fuel economy", "Possible limp mode"])
add("P0101", "Mass air flow (MAF) sensor reading out of expected range", "Air induction", "medium",
    ["Dirty or contaminated MAF sensor", "Air leak between MAF and throttle", "Blocked air filter", "Faulty MAF sensor"],
    ["Check engine light on", "Hesitation", "Poor fuel economy", "Rough idle"],
    ["Inspect air filter and intake ducting for leaks or cracks", "Compare MAF g/s at idle with engine size (roughly 2-4 g/s per litre at warm idle is typical)", "Clean the sensor with MAF-safe cleaner only"],
    ["Repair intake leaks", "Clean or replace MAF sensor", "Replace air filter"],
    ["Mass air flow sensor", "Air filter", "Intake ducting"])

for code, kind in [("P0105", "circuit"), ("P0107", "low"), ("P0108", "high")]:
    circuit_family(code, "Manifold absolute pressure (MAP) sensor", kind, "MAP sensor", "Air induction")
add("P0106", "Manifold absolute pressure (MAP) sensor reading out of expected range", "Air induction", "medium",
    ["Vacuum leak", "Cracked or blocked MAP sensor hose", "Faulty MAP sensor"],
    ["Check engine light on", "Rough idle", "Poor economy"],
    ["With engine off, MAP should read close to barometric pressure", "Check hose and vacuum lines", "Smoke test for intake leaks"],
    ["Repair vacuum leaks", "Replace MAP sensor"],
    ["MAP sensor", "Vacuum hoses"])

for code, kind in [("P0110", "circuit"), ("P0112", "low"), ("P0113", "high"), ("P0111", "range")]:
    circuit_family(code, "Intake air temperature (IAT) sensor", kind, "intake air temperature sensor", "Air induction", severity="low",
                   symptoms=["Check engine light on", "Usually little effect on driving", "Possible hard starting in extreme temperatures"])

for code, kind in [("P0115", "circuit"), ("P0117", "low"), ("P0118", "high"), ("P0116", "range")]:
    circuit_family(code, "Engine coolant temperature (ECT) sensor", kind, "coolant temperature sensor", "Cooling system", severity="medium",
                   symptoms=["Check engine light on", "Cooling fans may run constantly", "Hard starting or poor economy", "Temperature gauge may read wrongly"])
for code, kind in [("P0120", "circuit"), ("P0122", "low"), ("P0123", "high"), ("P0121", "range")]:
    circuit_family(code, "Throttle position sensor A", kind, "throttle position sensor", "Throttle control", severity="high",
                   symptoms=["Check engine light on", "Hesitation or surging", "Reduced power or limp mode"])
for code, kind in [("P0220", "circuit"), ("P0222", "low"), ("P0223", "high")]:
    circuit_family(code, "Throttle position sensor B", kind, "throttle position sensor", "Throttle control", severity="high",
                   symptoms=["Check engine light on", "Reduced power or limp mode"])

add("P0125", "Coolant takes too long to reach the temperature needed for closed-loop fuel control", "Cooling system", "low",
    ["Thermostat stuck open", "Faulty coolant temperature sensor", "Low coolant level"],
    ["Check engine light on", "Slow warm-up and weak cabin heat", "Higher fuel use"],
    ["Check coolant level", "Watch coolant temperature in Live Data during warm-up", "Feel the upper radiator hose: it should stay cool until the thermostat opens"],
    ["Replace thermostat", "Replace coolant temperature sensor"],
    ["Thermostat", "Coolant temperature sensor"])
add("P0128", "Coolant temperature stays below the thermostat's regulating temperature", "Cooling system", "low",
    ["Thermostat stuck open or opening too early", "Faulty coolant temperature sensor", "Cooling fan running all the time"],
    ["Check engine light on", "Slow warm-up", "Weak heater", "Higher fuel use"],
    ["Monitor coolant temperature in Live Data on a drive: it should reach normal operating temperature", "Check whether the cooling fan runs when the engine is cold"],
    ["Replace thermostat", "Replace coolant temperature sensor if it reads incorrectly"],
    ["Thermostat", "Coolant temperature sensor", "Cooling fan control"])

# ---------------------------------------------------------------- oxygen sensors
O2 = [
    ("circuit", "circuit fault"), ("low", "signal voltage low"), ("high", "signal voltage high"),
    ("slow", "slow response"), ("noact", "no activity detected"), ("heater", "heater circuit fault"),
]
def o2_family(base, bank, sensor):
    for i, (kind, word) in enumerate(O2):
        code = f"P{base + i:04d}"
        pos = "upstream (before catalyst)" if sensor == 1 else "downstream (after catalyst)"
        name = f"Oxygen sensor bank {bank} sensor {sensor}"
        if kind == "heater":
            add(code, f"{name}: heater circuit fault", "Oxygen sensors", "low",
                ["Failed heater element", "Blown heater fuse", "Damaged wiring or connector"],
                ["Check engine light on", "Slower switch to closed-loop fuel control"],
                ["Check heater fuse", "Measure heater resistance", "Check heater supply voltage"],
                ["Replace the oxygen sensor", "Repair wiring or fuse"],
                [f"{name} ({pos})"])
            continue
        causes = {
            "circuit": ["Open or shorted sensor wiring", "Faulty oxygen sensor", "Exhaust leak near the sensor"],
            "low": ["Lean running condition (air leak, low fuel pressure)", "Exhaust leak before the sensor", "Signal wire shorted to ground", "Faulty sensor"],
            "high": ["Rich running condition (leaking injector, high fuel pressure)", "Signal shorted to voltage", "Fuel or coolant contamination of the sensor", "Faulty sensor"],
            "slow": ["Ageing or contaminated oxygen sensor", "Exhaust leak", "Oil or coolant burning contaminating the sensor"],
            "noact": ["Sensor not switching: failed sensor", "Open signal circuit", "Sensor heater not working", "Exhaust leak"],
        }[kind]
        add(code, f"{name}: {word}", "Oxygen sensors", "medium" if sensor == 1 else "low",
            causes,
            ["Check engine light on"] + (["Possible poor fuel economy or rough running"] if sensor == 1 else ["Usually no change in driving feel"]),
            ["Watch the sensor voltage in Live Data: a warm upstream narrow-band sensor normally switches between about 0.1 and 0.9 V",
             "Check for exhaust leaks ahead of the sensor", "Inspect wiring and connector", "Check fuel trims for a lean or rich condition"],
            ["Fix any lean/rich condition or exhaust leak first", "Replace the oxygen sensor if it is slow or dead"],
            [f"{name} ({pos})"])
o2_family(130, 1, 1); o2_family(136, 1, 2); o2_family(150, 2, 1); o2_family(156, 2, 2)

for code, bank, lean in [("P0171", 1, True), ("P0172", 1, False), ("P0174", 2, True), ("P0175", 2, False)]:
    if lean:
        add(code, f"Fuel mixture too lean (bank {bank}): the engine is getting too much air or too little fuel", "Fuel and air metering", "medium",
            ["Vacuum or intake air leak (hoses, intake gasket, PCV)", "Dirty or faulty MAF sensor under-reading air flow", "Low fuel pressure (weak pump, clogged filter)", "Clogged or leaking injectors", "Exhaust leak before the upstream oxygen sensor"],
            ["Check engine light on", "Hesitation or stumbling on acceleration", "Rough idle", "Possible misfire codes"],
            ["Check long-term fuel trim: values above about +10% confirm the engine is adding fuel to compensate",
             "If trims are high at idle but improve at higher RPM, suspect a vacuum leak; if they worsen under load, suspect fuel delivery",
             "Smoke test the intake for leaks", "Inspect and clean the MAF sensor", "Test fuel pressure"],
            ["Repair vacuum leaks", "Clean or replace MAF sensor", "Replace fuel filter or pump if pressure is low", "Clean or replace injectors"],
            ["Intake manifold and vacuum hoses", "PCV system", "Mass air flow sensor", "Fuel pump and filter", "Injectors"])
    else:
        add(code, f"Fuel mixture too rich (bank {bank}): the engine is getting too much fuel or too little air", "Fuel and air metering", "medium",
            ["Leaking or stuck-open injector", "High fuel pressure (faulty regulator)", "MAF sensor over-reading", "Faulty coolant temperature sensor reading cold", "Restricted air filter", "Leaking purge valve flooding the intake with fuel vapour"],
            ["Check engine light on", "Poor fuel economy", "Fuel smell or black smoke", "Rough idle"],
            ["Check long-term fuel trim: values below about -10% confirm the engine is removing fuel",
             "Check coolant temperature reading is correct", "Test fuel pressure", "Check purge valve does not leak when closed"],
            ["Replace leaking injector or regulator", "Clean or replace MAF sensor", "Replace purge valve"],
            ["Injectors", "Fuel pressure regulator", "Mass air flow sensor", "Coolant temperature sensor", "EVAP purge valve"])

for code, kind in [("P0190", "circuit"), ("P0192", "low"), ("P0193", "high"), ("P0191", "range")]:
    circuit_family(code, "Fuel rail pressure sensor", kind, "fuel rail pressure sensor", "Fuel system", severity="high",
                   symptoms=["Check engine light on", "Hard starting", "Loss of power or limp mode"])

add("P0200", "Fuel injector control circuit fault", "Fuel system", "high",
    ["Open or shorted injector wiring", "Faulty injector", "Injector driver fault in the engine control module"],
    ["Check engine light on", "Misfire", "Rough running"],
    ["Check for misfire codes that point to a cylinder", "Measure injector resistance", "Inspect harness and connectors"],
    ["Repair wiring", "Replace faulty injector"],
    ["Fuel injectors", "Injector wiring"])
for cyl in range(1, 9):
    add(f"P020{cyl}", f"Fuel injector cylinder {cyl}: circuit fault or open", "Fuel system", "high",
        [f"Open or shorted wiring to injector {cyl}", f"Failed injector {cyl}", "Connector fault"],
        ["Check engine light on", f"Misfire on cylinder {cyl}", "Rough running", "Reduced power"],
        [f"Measure injector {cyl} resistance and compare with the other injectors", "Check for supply voltage at the injector connector", "Inspect wiring for damage"],
        ["Repair wiring or connector", f"Replace injector {cyl}"],
        [f"Fuel injector cylinder {cyl}"])

add("P0217", "Engine coolant over-temperature", "Cooling system", "critical",
    ["Low coolant or coolant leak", "Failed cooling fan or fan control", "Stuck thermostat", "Failed water pump", "Blocked radiator", "Head gasket failure"],
    ["Temperature gauge high or warning light", "Steam from engine bay", "Loss of power (engine protection)"],
    ["Stop the engine safely and let it cool before opening the cooling system", "Check coolant level and look for leaks", "Check fans run when hot", "Check for exhaust gas in coolant if overheating repeats"],
    ["Repair leak and refill coolant", "Repair fan or fan control", "Replace thermostat or water pump"],
    ["Coolant", "Radiator", "Cooling fan", "Thermostat", "Water pump"])
add("P0219", "Engine over-speed condition recorded", "Engine", "medium",
    ["Engine revved past its limit (missed gear change)", "Faulty speed sensor signal"],
    ["Usually none after the event", "Possible engine damage if severe"],
    ["Ask how the vehicle was driven", "Check crankshaft sensor signal", "Listen for valve-train noise"],
    ["Clear code and monitor", "Inspect engine if noises present"],
    ["Engine", "Crankshaft position sensor"])
add("P0230", "Fuel pump primary circuit fault", "Fuel system", "high",
    ["Failed fuel pump relay", "Blown fuel pump fuse", "Open or shorted wiring", "Inertia/crash switch tripped"],
    ["Engine cranks but does not start", "Engine stalls"],
    ["Check fuel pump fuse and relay", "Listen for the pump priming at ignition on", "Check voltage at the pump connector"],
    ["Replace relay or fuse", "Repair wiring", "Reset inertia switch"],
    ["Fuel pump relay", "Fuel pump fuse", "Fuel pump wiring"])
add("P0234", "Turbocharger or supercharger overboost", "Forced induction", "high",
    ["Wastegate stuck closed", "Faulty boost control solenoid", "Sticking variable-geometry vanes", "Faulty boost pressure sensor"],
    ["Check engine light on", "Limp mode", "Surging power"],
    ["Compare desired and actual boost in Live Data", "Check wastegate actuator movement", "Check vacuum lines to the boost control solenoid"],
    ["Free or replace wastegate actuator", "Replace boost control solenoid", "Clean or repair turbo vanes"],
    ["Turbocharger", "Wastegate", "Boost control solenoid", "Boost pressure sensor"])
add("P0299", "Turbocharger or supercharger underboost", "Forced induction", "medium",
    ["Boost leak (split intercooler hose or loose clamp)", "Wastegate stuck open", "Sticking variable-geometry vanes", "Worn turbocharger", "Faulty boost control solenoid"],
    ["Loss of power", "Limp mode", "Whistling or hissing under acceleration"],
    ["Inspect intercooler hoses and clamps", "Compare desired and actual boost in Live Data", "Check turbo shaft play and actuator movement"],
    ["Repair boost leaks", "Repair wastegate or vane control", "Replace turbocharger if worn"],
    ["Intercooler hoses", "Turbocharger", "Wastegate", "Boost control solenoid"])

# ---------------------------------------------------------------- misfire
MISFIRE_CAUSES = ["Worn or fouled spark plug", "Faulty ignition coil", "Clogged or leaking injector", "Vacuum leak", "Low compression (valves, rings, head gasket)"]
add("P0300", "Random or multiple cylinder misfire detected", "Ignition / misfire", "high",
    ["Worn spark plugs or ignition coils", "Vacuum leak", "Low fuel pressure", "Lean mixture", "EGR fault", "Low compression"],
    ["Check engine light on or flashing", "Rough running and shaking", "Loss of power", "Fuel smell"],
    ["If the check engine light is flashing, reduce load and avoid driving: unburnt fuel can overheat the catalytic converter",
     "Check misfire counts per cylinder if available", "Check fuel trims for a lean condition", "Inspect spark plugs and coils", "Do a compression test if one cylinder stands out"],
    ["Replace spark plugs and faulty coils", "Repair vacuum leak", "Repair fuel delivery"],
    ["Spark plugs", "Ignition coils", "Injectors", "Intake system"])
for cyl in range(1, 9):
    add(f"P030{cyl}", f"Misfire detected in cylinder {cyl}", "Ignition / misfire", "high",
        MISFIRE_CAUSES,
        ["Check engine light on or flashing", "Rough running", "Loss of power"],
        ["Avoid hard driving if the check engine light flashes", f"Swap the cylinder {cyl} coil with a neighbouring cylinder and see whether the misfire moves",
         f"Inspect the cylinder {cyl} spark plug", f"Check injector {cyl}", f"Compression test cylinder {cyl}"],
        ["Replace the faulty coil or spark plug", "Replace or clean injector", "Repair mechanical faults found by compression test"],
        [f"Spark plug cylinder {cyl}", f"Ignition coil cylinder {cyl}", f"Injector cylinder {cyl}"])
add("P0313", "Misfire detected with low fuel level", "Ignition / misfire", "medium",
    ["Running the tank very low causing fuel starvation", "Weak fuel pump"],
    ["Rough running when fuel is low"],
    ["Fill the tank and confirm whether the misfire stops", "Check fuel pressure"],
    ["Keep fuel above a quarter tank", "Replace weak fuel pump"],
    ["Fuel pump", "Fuel level"])
add("P0316", "Misfire detected during the first moments after start-up", "Ignition / misfire", "medium",
    ["Worn spark plugs", "Leaking injector", "Moisture in ignition components", "Low compression"],
    ["Rough start that smooths out"],
    ["Check for other misfire codes", "Inspect spark plugs and coils", "Check for leaking injectors"],
    ["Replace worn ignition parts", "Replace leaking injector"],
    ["Spark plugs", "Ignition coils", "Injectors"])

# ---------------------------------------------------------------- knock, crank, cam
for code, sensor, kind in [("P0325", 1, "circuit"), ("P0327", 1, "low"), ("P0328", 1, "high"), ("P0330", 2, "circuit"), ("P0332", 2, "low"), ("P0333", 2, "high")]:
    circuit_family(code, f"Knock sensor {sensor}", kind, "knock sensor", "Ignition / misfire", severity="medium",
                   symptoms=["Check engine light on", "Reduced power (ignition timing retarded for protection)", "Possible pinging"])
for code, kind in [("P0335", "circuit"), ("P0337", "low"), ("P0338", "high"), ("P0336", "range"), ("P0339", "intermittent")]:
    circuit_family(code, "Crankshaft position sensor A", kind, "crankshaft position sensor", "Engine timing", severity="high",
                   symptoms=["Engine may crank but not start", "Engine may cut out while driving", "Tachometer may drop to zero"])
for code, part, kind in [("P0340", "Camshaft position sensor A (bank 1)", "circuit"), ("P0342", "Camshaft position sensor A (bank 1)", "low"),
                         ("P0343", "Camshaft position sensor A (bank 1)", "high"), ("P0341", "Camshaft position sensor A (bank 1)", "range"),
                         ("P0345", "Camshaft position sensor A (bank 2)", "circuit"), ("P0365", "Camshaft position sensor B (bank 1)", "circuit"),
                         ("P0366", "Camshaft position sensor B (bank 1)", "range")]:
    circuit_family(code, part, kind, "camshaft position sensor", "Engine timing", severity="medium",
                   symptoms=["Check engine light on", "Longer cranking time", "Possible stalling or rough running"])
for i, letter in enumerate("ABCDEFGH"):
    add(f"P035{i + 1}", f"Ignition coil {letter}: primary or secondary circuit fault", "Ignition / misfire", "high",
        [f"Failed ignition coil {letter}", "Open or shorted coil wiring", "Connector fault"],
        ["Check engine light on", "Misfire on the matching cylinder (coil A is usually cylinder 1)", "Rough running"],
        ["Check coil supply voltage and control signal", "Inspect connector", "Swap the coil with another cylinder to confirm"],
        ["Repair wiring", f"Replace ignition coil {letter}"],
        [f"Ignition coil {letter}"])
add("P0380", "Glow plug / heater circuit A fault", "Diesel starting", "medium",
    ["Failed glow plug(s)", "Faulty glow plug control module or relay", "Wiring fault"],
    ["Hard starting when cold", "White smoke on cold start"],
    ["Measure each glow plug resistance", "Check supply from the glow plug module", "Inspect busbar and wiring"],
    ["Replace failed glow plugs", "Replace glow plug control module"],
    ["Glow plugs", "Glow plug control module"])

# ---------------------------------------------------------------- emissions
add("P0400", "Exhaust gas recirculation (EGR) flow fault", "EGR", "medium",
    ["Carbon-clogged EGR valve or passages", "Faulty EGR valve", "Vacuum or wiring fault to the EGR valve"],
    ["Check engine light on", "Pinging under load or rough idle"],
    ["Command the EGR valve if supported and watch the response", "Inspect EGR passages for carbon", "Check EGR valve wiring/vacuum"],
    ["Clean EGR valve and passages", "Replace EGR valve"],
    ["EGR valve", "EGR passages"])
add("P0401", "Exhaust gas recirculation (EGR) flow insufficient", "EGR", "medium",
    ["Carbon build-up blocking the EGR valve or passages", "EGR valve not opening", "Faulty EGR position or DPFE sensor", "Vacuum supply fault"],
    ["Check engine light on", "Engine knock (pinging) under load", "Higher NOx emissions"],
    ["Inspect and clean EGR passages", "Check EGR valve opens when commanded", "Test the EGR position or pressure sensor"],
    ["Clean EGR system", "Replace EGR valve or sensor"],
    ["EGR valve", "EGR passages", "EGR sensor"])
add("P0402", "Exhaust gas recirculation (EGR) flow excessive", "EGR", "medium",
    ["EGR valve stuck open", "Faulty EGR control solenoid", "Faulty EGR position sensor"],
    ["Rough idle or stalling", "Hesitation"],
    ["Check EGR valve closes fully", "Check EGR position reading at idle", "Inspect control solenoid"],
    ["Clean or replace EGR valve", "Replace control solenoid"],
    ["EGR valve", "EGR control solenoid"])
add("P0403", "Exhaust gas recirculation (EGR) control circuit fault", "EGR", "medium",
    ["Open or shorted wiring to the EGR valve/solenoid", "Failed EGR solenoid"],
    ["Check engine light on"],
    CIRCUIT_INSPECT, ["Repair wiring", "Replace EGR valve or solenoid"], ["EGR valve", "EGR control solenoid"])
add("P0404", "Exhaust gas recirculation (EGR) control range or performance fault", "EGR", "medium",
    ["Sticking EGR valve", "Carbon build-up", "Faulty EGR position sensor"],
    ["Check engine light on", "Rough idle"],
    ["Compare commanded and actual EGR position", "Inspect EGR valve for carbon"],
    ["Clean or replace EGR valve"], ["EGR valve"])
circuit_family("P0405", "EGR sensor A", "low", "EGR position sensor", "EGR")
circuit_family("P0406", "EGR sensor A", "high", "EGR position sensor", "EGR")
add("P0410", "Secondary air injection system fault", "Secondary air", "low",
    ["Failed secondary air pump", "Stuck check valve", "Blown fuse or relay", "Leaking hoses"],
    ["Check engine light on", "Noise from air pump on cold start"],
    ["Listen for the pump running on a cold start", "Check fuse and relay", "Inspect hoses and check valve"],
    ["Replace air pump, check valve or relay"], ["Secondary air pump", "Check valve"])
add("P0411", "Secondary air injection: incorrect flow detected", "Secondary air", "low",
    ["Blocked or leaking air passages", "Failing air pump", "Stuck check valve"],
    ["Check engine light on"],
    ["Check pump output and hoses", "Inspect check valve"],
    ["Repair hoses or replace pump/check valve"], ["Secondary air pump", "Check valve", "Air hoses"])
for code, bank in [("P0420", 1), ("P0430", 2)]:
    add(code, f"Catalytic converter efficiency below threshold (bank {bank})", "Catalytic converter", "medium",
        ["Worn or damaged catalytic converter", "Exhaust leak near the oxygen sensors", "Faulty downstream oxygen sensor", "Engine running rich or misfiring and damaging the catalyst"],
        ["Check engine light on", "Usually no driving symptoms", "Possible sulphur smell", "Will fail an emissions test"],
        ["Fix any misfire or fuel trim code first", "Check for exhaust leaks", "Compare upstream and downstream O2 sensors: the downstream one should stay fairly steady when the catalyst works"],
        ["Repair exhaust leaks", "Replace downstream oxygen sensor if faulty", "Replace catalytic converter"],
        [f"Catalytic converter bank {bank}", "Downstream oxygen sensor"])
add("P0440", "Evaporative emission (EVAP) system fault", "EVAP", "low",
    ["Loose or faulty fuel cap", "Leaking EVAP hose", "Faulty purge or vent valve", "Leaking charcoal canister"],
    ["Check engine light on", "Possible fuel smell"],
    ["Check the fuel cap seal and tightness", "Smoke test the EVAP system", "Test purge and vent valves"],
    ["Replace fuel cap", "Repair leaking hose", "Replace faulty valve or canister"],
    ["Fuel cap", "EVAP hoses", "Purge valve", "Vent valve", "Charcoal canister"])
add("P0441", "Evaporative emission (EVAP) system: incorrect purge flow", "EVAP", "low",
    ["Faulty purge valve (stuck open or closed)", "Blocked or split purge hose", "Blocked canister"],
    ["Check engine light on", "Possible rough idle after refuelling"],
    ["Check purge valve opens and closes when commanded", "Inspect purge hoses"],
    ["Replace purge valve", "Repair hoses"], ["Purge valve", "Purge hoses"])
add("P0442", "Evaporative emission (EVAP) system: small leak detected", "EVAP", "low",
    ["Fuel cap seal worn", "Small crack in an EVAP hose", "Leaking vent or purge valve"],
    ["Check engine light on", "Usually no other symptoms"],
    ["Check and reseat the fuel cap", "Smoke test the EVAP system"],
    ["Replace fuel cap", "Repair leak"], ["Fuel cap", "EVAP hoses", "Vent valve"])
add("P0443", "Evaporative emission (EVAP) purge valve circuit fault", "EVAP", "low",
    ["Open or shorted purge valve wiring", "Failed purge valve"],
    ["Check engine light on"], CIRCUIT_INSPECT, ["Repair wiring", "Replace purge valve"], ["Purge valve"])
add("P0446", "Evaporative emission (EVAP) vent control circuit fault", "EVAP", "low",
    ["Blocked or stuck vent valve", "Wiring fault", "Blocked vent filter"],
    ["Check engine light on", "Possible difficulty refuelling"],
    ["Check vent valve operation", "Inspect vent filter and hoses", "Check wiring"],
    ["Replace vent valve", "Clear blockage"], ["Vent valve", "Vent filter"])
add("P0449", "Evaporative emission (EVAP) vent valve/solenoid circuit fault", "EVAP", "low",
    ["Failed vent solenoid", "Open or shorted wiring"],
    ["Check engine light on"], CIRCUIT_INSPECT, ["Repair wiring", "Replace vent solenoid"], ["Vent solenoid"])
add("P0451", "Fuel tank pressure sensor reading out of expected range", "EVAP", "low",
    ["Faulty tank pressure sensor", "Blocked sensor port", "Wiring fault"],
    ["Check engine light on"],
    ["Compare tank pressure reading with cap removed (should be near zero)", "Inspect wiring"],
    ["Replace tank pressure sensor"], ["Fuel tank pressure sensor"])
circuit_family("P0452", "Fuel tank pressure sensor", "low", "fuel tank pressure sensor", "EVAP", severity="low", symptoms=["Check engine light on"])
circuit_family("P0453", "Fuel tank pressure sensor", "high", "fuel tank pressure sensor", "EVAP", severity="low", symptoms=["Check engine light on"])
add("P0455", "Evaporative emission (EVAP) system: large leak or no flow detected", "EVAP", "low",
    ["Fuel cap missing or not tightened", "Disconnected or split EVAP hose", "Faulty purge or vent valve", "Damaged canister"],
    ["Check engine light on", "Fuel smell possible"],
    ["Check the fuel cap first", "Smoke test the EVAP system", "Inspect hoses near the tank and canister"],
    ["Fit or replace fuel cap", "Reconnect or replace hose", "Replace faulty valve"],
    ["Fuel cap", "EVAP hoses", "Charcoal canister"])
add("P0456", "Evaporative emission (EVAP) system: very small leak detected", "EVAP", "low",
    ["Worn fuel cap seal", "Pin-hole leak in a hose or seal", "Slight leak at the vent or purge valve"],
    ["Check engine light on", "No driving symptoms"],
    ["Replace or reseat the fuel cap", "Smoke test with a high-sensitivity smoke machine"],
    ["Replace fuel cap", "Repair leak"], ["Fuel cap", "EVAP hoses"])
add("P0457", "Evaporative emission (EVAP) leak detected: fuel cap loose or off", "EVAP", "low",
    ["Fuel cap not tightened after refuelling", "Fuel cap seal damaged"],
    ["Check engine light on"],
    ["Tighten or replace the fuel cap", "Clear the code and drive normally to confirm"],
    ["Tighten or replace fuel cap"], ["Fuel cap"])
for code, kind in [("P0460", "circuit"), ("P0462", "low"), ("P0463", "high"), ("P0461", "range")]:
    circuit_family(code, "Fuel level sensor A", kind, "fuel level sensor", "Fuel system", severity="low",
                   symptoms=["Check engine light on", "Fuel gauge reads wrongly or fluctuates"])
add("P0480", "Cooling fan 1 control circuit fault", "Cooling system", "high",
    ["Failed fan relay", "Blown fan fuse", "Failed fan motor", "Wiring fault"],
    ["Engine may overheat in traffic", "A/C may perform poorly at idle"],
    ["Watch coolant temperature: stop if it rises abnormally", "Command the fan with a scan tool if supported", "Check fuse, relay and fan motor"],
    ["Replace relay, fuse or fan motor", "Repair wiring"],
    ["Cooling fan", "Fan relay", "Fan fuse"])

# ---------------------------------------------------------------- speed, idle, power
for code, kind in [("P0500", "circuit"), ("P0502", "low"), ("P0501", "range"), ("P0503", "intermittent")]:
    circuit_family(code, "Vehicle speed sensor A", kind, "vehicle speed sensor", "Vehicle speed", severity="medium",
                   symptoms=["Check engine light on", "Speedometer wrong or not working", "Harsh or incorrect gear changes", "ABS or cruise control may be disabled"])
add("P0505", "Idle air control system fault", "Idle control", "medium",
    ["Dirty throttle body or idle air valve", "Failed idle control valve", "Vacuum leak"],
    ["Unstable or wrong idle speed", "Stalling"],
    ["Clean throttle body/idle air passage", "Check for vacuum leaks", "Check idle valve operation"],
    ["Clean or replace idle control valve", "Repair vacuum leak"], ["Idle air control valve", "Throttle body"])
add("P0506", "Idle speed lower than expected", "Idle control", "low",
    ["Dirty throttle body", "Restricted air intake", "Idle control fault", "Heavy engine load at idle (e.g. A/C, alternator)"],
    ["Low or rough idle", "Possible stalling"],
    ["Compare desired and actual idle in Live Data", "Clean throttle body"],
    ["Clean throttle body", "Perform idle relearn if required"], ["Throttle body", "Idle control"])
add("P0507", "Idle speed higher than expected", "Idle control", "low",
    ["Vacuum leak", "Dirty or sticking throttle body", "Idle control valve stuck open"],
    ["High idle speed"],
    ["Smoke test for vacuum leaks", "Inspect throttle plate", "Compare desired and actual idle"],
    ["Repair vacuum leak", "Clean throttle body", "Perform idle relearn"], ["Throttle body", "Intake hoses"])
for code, kind in [("P0520", "circuit"), ("P0522", "low"), ("P0523", "high"), ("P0521", "range")]:
    circuit_family(code, "Engine oil pressure sensor/switch", kind, "oil pressure sensor", "Lubrication", severity="high",
                   symptoms=["Oil pressure warning may light", "Oil pressure gauge reads wrongly"],
                   extra_causes=["Genuinely low oil pressure: check oil level before driving"])
add("P0524", "Engine oil pressure too low", "Lubrication", "critical",
    ["Low oil level", "Wrong oil grade or very old oil", "Worn oil pump or bearings", "Blocked oil pickup", "Faulty oil pressure sensor"],
    ["Oil pressure warning light", "Engine noise (ticking or knocking)"],
    ["Stop the engine as soon as it is safe: running without oil pressure destroys the engine", "Check the oil level", "Verify pressure with a mechanical gauge before replacing parts"],
    ["Top up or change oil", "Replace faulty sensor", "Repair oil pump or engine if pressure is genuinely low"],
    ["Engine oil", "Oil pump", "Oil pressure sensor"])
for code, kind in [("P0530", "circuit"), ("P0532", "low"), ("P0533", "high")]:
    circuit_family(code, "A/C refrigerant pressure sensor A", kind, "A/C pressure sensor", "Air conditioning", severity="low",
                   symptoms=["Air conditioning may not work", "Cooling fan may run constantly"],
                   extra_causes=["Low refrigerant charge"] if kind == "low" else None)
add("P0560", "System voltage fault", "Charging system", "medium",
    ["Weak battery", "Charging system fault", "Poor battery or ground connection"],
    ["Electrical faults", "Possible starting problems"],
    ["Check battery voltage: about 12.6 V engine off and roughly 13.5-14.8 V running is typical", "Clean and tighten battery terminals and grounds", "Test alternator output"],
    ["Charge or replace battery", "Repair connections", "Repair charging system"],
    ["Battery", "Alternator", "Battery cables"])
add("P0562", "System voltage low", "Charging system", "medium",
    ["Weak or failing battery", "Alternator not charging", "Loose or corroded battery terminals", "Slipping drive belt"],
    ["Battery warning light", "Dim lights", "Hard starting", "Other electrical warnings"],
    ["Measure battery voltage with the engine running", "Check alternator belt and connections", "Load-test the battery"],
    ["Repair connections", "Replace alternator or battery"],
    ["Battery", "Alternator", "Drive belt"])
add("P0563", "System voltage high", "Charging system", "medium",
    ["Faulty alternator voltage regulator", "Poor regulator sense connection"],
    ["Bulbs failing early", "Battery overheating or smelling", "Electrical warnings"],
    ["Measure charging voltage: above about 15 V is too high", "Check regulator connections"],
    ["Replace alternator/regulator"], ["Alternator", "Voltage regulator"])
add("P0571", "Brake switch A circuit fault", "Brakes / switches", "medium",
    ["Faulty or misadjusted brake light switch", "Wiring fault", "Blown fuse"],
    ["Brake lights may not work", "Cruise control may not work", "Possible difficulty shifting out of Park"],
    ["Check brake lights work", "Check brake switch adjustment and signal in Live Data if available"],
    ["Adjust or replace brake light switch"], ["Brake light switch"])

# ---------------------------------------------------------------- control module
for code, desc in [("P0600", "Control module serial communication link fault"),
                   ("P0601", "Control module internal memory checksum error"),
                   ("P0602", "Control module programming error"),
                   ("P0603", "Control module internal keep-alive memory (KAM) error"),
                   ("P0604", "Control module internal random access memory (RAM) error"),
                   ("P0605", "Control module internal read-only memory (ROM) error"),
                   ("P0606", "Control module processor fault")]:
    add(code, desc, "Control module", "high",
        ["Internal control module fault", "Interrupted or incomplete software update", "Poor power or ground supply to the module", "Water ingress into the module"],
        ["Check engine light on", "Possible no start, stalling or limp mode"],
        ["Check battery voltage and module power and ground circuits first", "Look for water damage", "Check for software updates from the manufacturer"],
        ["Repair power or ground faults", "Reprogram or replace the control module (needs a dealer-level procedure)"],
        ["Engine control module", "Module power and ground"])
add("P0615", "Starter relay circuit fault", "Starting system", "medium",
    ["Failed starter relay", "Wiring fault"],
    ["Engine may not crank"],
    CIRCUIT_INSPECT, ["Replace starter relay", "Repair wiring"], ["Starter relay"])
add("P0620", "Generator (alternator) control circuit fault", "Charging system", "medium",
    ["Faulty alternator", "Wiring fault between module and alternator"],
    ["Battery warning light", "Low charging voltage"],
    ["Measure charging voltage", "Inspect alternator connector and wiring"],
    ["Repair wiring", "Replace alternator"], ["Alternator"])
add("P0621", "Generator (alternator) lamp control circuit fault", "Charging system", "low",
    ["Wiring fault on the alternator lamp circuit", "Faulty alternator"],
    ["Battery warning light behaves incorrectly"],
    ["Check charging voltage", "Inspect lamp circuit wiring"],
    ["Repair wiring", "Replace alternator"], ["Alternator", "Instrument cluster lamp circuit"])
add("P0622", "Generator (alternator) field control circuit fault", "Charging system", "medium",
    ["Faulty alternator regulator", "Wiring fault"],
    ["Battery warning light", "Battery not charging"],
    ["Measure charging voltage", "Check field circuit wiring"],
    ["Replace alternator", "Repair wiring"], ["Alternator"])
add("P0627", "Fuel pump A control circuit open or faulty", "Fuel system", "high",
    ["Fuel pump control module fault", "Open wiring", "Failed fuel pump"],
    ["Engine may not start or may stall"],
    CIRCUIT_INSPECT, ["Repair wiring", "Replace pump control module or pump"], ["Fuel pump", "Fuel pump control module"])
for code, ref in [("P0641", "A"), ("P0651", "B")]:
    add(code, f"Sensor reference voltage {ref} circuit fault", "Control module", "high",
        ["A sensor on this 5 V reference circuit is shorted", "Damaged wiring shorting the reference to ground", "Control module fault"],
        ["Several sensor codes at once", "Limp mode", "Possible no start"],
        ["Unplug sensors on that reference one at a time while watching the reference voltage", "Inspect wiring for chafing"],
        ["Replace the shorted sensor", "Repair wiring"], ["5 V sensor reference circuit", "Sensors sharing the reference"])

# ---------------------------------------------------------------- transmission
add("P0700", "Transmission control system fault (transmission module has stored a code)", "Transmission", "medium",
    ["The transmission control module has its own fault code stored"],
    ["Check engine light on", "Possible harsh shifts or limp mode"],
    ["Read codes from the transmission control module (enhanced diagnostics) to find the actual fault"],
    ["Repair the fault reported by the transmission module"], ["Transmission control module"])
circuit_family("P0705", "Transmission range sensor A (gear selector position)", "circuit", "transmission range sensor", "Transmission", severity="medium",
               symptoms=["Wrong gear shown", "May not start in Park/Neutral", "Harsh shifts"])
circuit_family("P0710", "Transmission fluid temperature sensor A", "circuit", "transmission fluid temperature sensor", "Transmission", severity="medium",
               symptoms=["Harsh or delayed shifts", "Torque converter may not lock up"])
circuit_family("P0715", "Transmission input/turbine speed sensor A", "circuit", "input speed sensor", "Transmission", severity="medium",
               symptoms=["Harsh shifts", "Limp mode", "Speedometer may misbehave"])
circuit_family("P0720", "Transmission output speed sensor", "circuit", "output speed sensor", "Transmission", severity="medium",
               symptoms=["Harsh shifts", "Speedometer wrong", "Limp mode"])
add("P0730", "Incorrect transmission gear ratio", "Transmission", "high",
    ["Low or degraded transmission fluid", "Slipping clutches or bands", "Faulty shift solenoid", "Faulty speed sensor"],
    ["Slipping", "Flare between gears", "Limp mode"],
    ["Check transmission fluid level and condition", "Read transmission module codes", "Compare input and output speed in Live Data"],
    ["Correct fluid level and condition", "Repair solenoid or valve body", "Transmission repair if internally worn"],
    ["Transmission fluid", "Shift solenoids", "Clutch packs"])
add("P0740", "Torque converter clutch solenoid circuit fault", "Transmission", "medium",
    ["Failed TCC solenoid", "Wiring fault", "Low fluid"],
    ["Higher fuel use at cruise", "Higher engine RPM at steady speed"],
    ["Check fluid level", "Check solenoid resistance and wiring"],
    ["Repair wiring", "Replace TCC solenoid"], ["Torque converter clutch solenoid"])
add("P0741", "Torque converter clutch: stuck off or poor performance", "Transmission", "medium",
    ["Worn torque converter clutch", "Faulty TCC solenoid", "Low or contaminated fluid"],
    ["Higher RPM at cruise", "Shudder", "Higher fuel use"],
    ["Check fluid level and condition", "Compare engine and turbine speed at cruise"],
    ["Fluid service", "Replace TCC solenoid or torque converter"], ["Torque converter", "TCC solenoid"])
for code, letter in [("P0750", "A"), ("P0755", "B")]:
    add(code, f"Shift solenoid {letter} fault", "Transmission", "medium",
        [f"Failed shift solenoid {letter}", "Wiring fault", "Low or dirty fluid"],
        ["Harsh or missing gear changes", "Limp mode"],
        ["Check fluid", "Check solenoid resistance and wiring"],
        ["Repair wiring", f"Replace shift solenoid {letter}"], [f"Shift solenoid {letter}"])
add("P0780", "Transmission shift malfunction", "Transmission", "medium",
    ["Low fluid", "Faulty shift solenoid", "Internal wear"],
    ["Incorrect or harsh shifts"],
    ["Check fluid", "Read transmission module codes"],
    ["Repair the underlying fault reported by the transmission module"], ["Transmission"])

# ---------------------------------------------------------------- P2xxx
add("P2002", "Diesel particulate filter (DPF) efficiency below threshold (bank 1)", "Diesel aftertreatment", "medium",
    ["Cracked or damaged DPF", "Faulty DPF differential pressure sensor", "Leaking pressure sensor hoses"],
    ["Check engine light on", "Possible black smoke"],
    ["Check DPF differential pressure in Live Data", "Inspect sensor hoses for splits", "Check exhaust for soot after the DPF"],
    ["Replace pressure sensor or hoses", "Replace DPF if damaged"], ["Diesel particulate filter", "DPF pressure sensor"])
for code, bank, lean in [("P2096", 1, True), ("P2097", 1, False), ("P2098", 2, True), ("P2099", 2, False)]:
    add(code, f"Post-catalyst fuel trim too {'lean' if lean else 'rich'} (bank {bank})", "Fuel and air metering", "medium",
        (["Exhaust leak near the downstream oxygen sensor", "Lean condition from vacuum leak or low fuel pressure", "Faulty downstream oxygen sensor"] if lean
         else ["Rich condition from leaking injector or high fuel pressure", "Faulty downstream oxygen sensor", "Worn catalytic converter"]),
        ["Check engine light on"],
        ["Check for exhaust leaks", "Check upstream fuel trims", "Check downstream oxygen sensor response"],
        ["Repair exhaust leak or fuel fault", "Replace downstream oxygen sensor"], ["Downstream oxygen sensor", "Exhaust system"])
add("P2101", "Throttle actuator control motor circuit range or performance fault", "Throttle control", "high",
    ["Dirty or sticking electronic throttle body", "Failed throttle motor", "Wiring fault", "Low system voltage"],
    ["Reduced power or limp mode", "Idle problems"],
    ["Inspect and clean throttle body", "Check wiring and connector", "Check battery voltage"],
    ["Clean throttle body and run a throttle relearn", "Replace throttle body"], ["Electronic throttle body"])
add("P2135", "Throttle/pedal position sensors A and B do not agree", "Throttle control", "high",
    ["Faulty throttle body position sensors", "Wiring fault", "Poor connector contact"],
    ["Limp mode", "Reduced power"],
    ["Compare throttle position sensor A and B readings", "Inspect throttle body connector"],
    ["Repair wiring", "Replace throttle body"], ["Electronic throttle body"])
add("P2138", "Accelerator pedal position sensors D and E do not agree", "Throttle control", "high",
    ["Faulty accelerator pedal sensor", "Wiring fault"],
    ["Limp mode", "Poor throttle response"],
    ["Compare pedal sensor D and E readings while slowly pressing the pedal", "Inspect pedal connector"],
    ["Replace accelerator pedal assembly", "Repair wiring"], ["Accelerator pedal position sensor"])
for code, lean, where in [("P2177", True, "off idle"), ("P2178", False, "off idle"), ("P2187", True, "at idle"), ("P2188", False, "at idle")]:
    add(code, f"Fuel mixture too {'lean' if lean else 'rich'} {where} (bank 1)", "Fuel and air metering", "medium",
        (["Vacuum leak" if where == "at idle" else "Low fuel pressure or dirty MAF sensor", "Intake air leak", "Clogged injectors"] if lean
         else ["Leaking injector", "High fuel pressure", "Leaking purge valve"]),
        ["Check engine light on", "Rough idle" if where == "at idle" else "Hesitation under load"],
        ["Check fuel trims at idle and at 2500 RPM", "Smoke test for leaks", "Test fuel pressure"],
        ["Repair leaks or fuel delivery fault"], ["Intake system", "Fuel system", "Mass air flow sensor"])
for code, s, lean in [("P2195", 1, True), ("P2196", 1, False), ("P2270", 2, True), ("P2271", 2, False)]:
    add(code, f"Oxygen sensor bank 1 sensor {s}: signal stuck {'lean' if lean else 'rich'}", "Oxygen sensors", "medium" if s == 1 else "low",
        (["Exhaust leak before the sensor", "Real lean condition", "Faulty oxygen sensor"] if lean else ["Real rich condition", "Fuel-contaminated sensor", "Faulty oxygen sensor"]),
        ["Check engine light on"],
        ["Check fuel trims", "Check for exhaust leaks", "Watch sensor voltage in Live Data"],
        ["Fix fuel or exhaust fault", "Replace oxygen sensor"], [f"Oxygen sensor bank 1 sensor {s}"])
add("P242F", "Diesel particulate filter (DPF) restriction: ash accumulation", "Diesel aftertreatment", "medium",
    ["DPF has reached its ash capacity (normal with high mileage)", "High oil consumption adding ash"],
    ["Check engine light on", "Reduced power", "Frequent regenerations"],
    ["Check DPF ash load if the vehicle reports it", "Check engine oil consumption"],
    ["Clean or replace the DPF (ash cannot be burnt off)"], ["Diesel particulate filter"])
add("P2463", "Diesel particulate filter (DPF) restriction: soot accumulation", "Diesel aftertreatment", "high",
    ["Many short journeys preventing regeneration", "Failed regenerations", "Faulty DPF pressure sensor", "Engine fault producing excess soot (EGR, injectors)"],
    ["DPF warning light", "Reduced power or limp mode"],
    ["Check soot load and differential pressure in Live Data", "Fix any engine fault codes first", "A sustained motorway drive may allow a regeneration if the manufacturer allows it"],
    ["Run a regeneration (drive or service tool)", "Clean or replace DPF if regeneration fails"], ["Diesel particulate filter", "DPF pressure sensor"])
circuit_family("P2452", "Diesel particulate filter (DPF) pressure sensor A", "circuit", "DPF pressure sensor", "Diesel aftertreatment")
circuit_family("P2453", "Diesel particulate filter (DPF) pressure sensor A", "range", "DPF pressure sensor", "Diesel aftertreatment",
               extra_causes=["Split, blocked or swapped sensor hoses"])
add("P20EE", "SCR NOx catalyst efficiency below threshold (bank 1)", "Diesel aftertreatment", "medium",
    ["Poor quality or contaminated AdBlue/DEF", "Faulty AdBlue dosing", "Faulty NOx sensor", "Worn SCR catalyst"],
    ["Check engine light on", "AdBlue warning", "Possible start countdown or power limit"],
    ["Check AdBlue quality and level", "Check NOx sensor readings before and after SCR", "Check dosing system"],
    ["Replace AdBlue", "Repair dosing system", "Replace NOx sensor or SCR catalyst"], ["SCR catalyst", "NOx sensors", "AdBlue dosing system"])
add("P0A80", "Hybrid battery pack needs replacement", "Hybrid system", "high",
    ["One or more hybrid battery modules weak or failed"],
    ["Hybrid warning light", "Reduced electric assist", "Poor fuel economy"],
    ["Compare hybrid battery block voltages if available (needs enhanced diagnostics)", "Check battery cooling fan and ducts"],
    ["Recondition or replace hybrid battery (high voltage: specialist work only)"], ["Hybrid battery pack", "Battery cooling fan"])

# ---------------------------------------------------------------- network (U)
for code, module in [("U0100", "engine control module (ECM/PCM)"), ("U0101", "transmission control module (TCM)"),
                     ("U0121", "anti-lock brake system (ABS) module"), ("U0140", "body control module (BCM)"),
                     ("U0151", "airbag/restraints control module"), ("U0155", "instrument cluster")]:
    add(code, f"Lost communication with the {module}", "Network communication", "high",
        [f"The {module} is not powered (fuse, power or ground fault)", "CAN bus wiring fault", f"Failed {module}", "Low battery voltage during cranking"],
        ["Warning lights on", "Related systems may not work", "Possible no start"],
        ["Check battery voltage", f"Check fuses and grounds for the {module}", "Check whether the module answers a scan", "Inspect CAN wiring and connectors"],
        ["Repair power, ground or bus wiring", f"Replace the {module} if it is dead"],
        [module[0].upper() + module[1:], "CAN bus wiring"])
add("U0001", "High-speed CAN communication bus fault", "Network communication", "high",
    ["Shorted or open CAN wiring", "A module pulling the bus down", "Water ingress in a connector"],
    ["Multiple warning lights", "Several modules not communicating"],
    ["Measure CAN-H/CAN-L resistance at the diagnostic port with battery disconnected (about 60 ohms is typical)", "Disconnect modules one at a time to find a faulty one"],
    ["Repair wiring", "Replace faulty module"], ["CAN bus wiring", "Control modules"])
add("U0073", "Control module communication bus A off", "Network communication", "high",
    ["CAN bus wiring fault", "Faulty module on the bus"],
    ["Multiple warning lights", "Systems not working"],
    ["Check CAN bus resistance and voltages", "Inspect wiring and connectors"],
    ["Repair bus wiring", "Replace faulty module"], ["CAN bus wiring"])
add("U0401", "Invalid data received from the engine control module", "Network communication", "medium",
    ["Engine module has a fault affecting the data it sends", "Software mismatch between modules"],
    ["Warning lights on another module"],
    ["Read codes from the engine module and fix those first", "Check for software updates"],
    ["Repair the engine module fault", "Update software"], ["Engine control module"])

# ---------------------------------------------------------------- write
def main():
    defs = sorted(CODES.values(), key=lambda d: d["code"])
    out = {"pack": PACK, "definitions": defs}
    path = os.path.join(os.path.dirname(__file__), "..", "app", "assets", "dtc", "rogue_generic.json")
    with open(path, "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, indent=1)
    print(f"wrote {len(defs)} definitions to {os.path.normpath(path)}")

if __name__ == "__main__":
    main()
