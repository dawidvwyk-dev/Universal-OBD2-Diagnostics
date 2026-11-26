// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $VehiclesTable extends Vehicles with TableInfo<$VehiclesTable, Vehicle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _registrationMeta = const VerificationMeta(
    'registration',
  );
  @override
  late final GeneratedColumn<String> registration = GeneratedColumn<String>(
    'registration',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vinMeta = const VerificationMeta('vin');
  @override
  late final GeneratedColumn<String> vin = GeneratedColumn<String>(
    'vin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _manufacturerMeta = const VerificationMeta(
    'manufacturer',
  );
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
    'manufacturer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _engineMeta = const VerificationMeta('engine');
  @override
  late final GeneratedColumn<String> engine = GeneratedColumn<String>(
    'engine',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelYearMeta = const VerificationMeta(
    'modelYear',
  );
  @override
  late final GeneratedColumn<int> modelYear = GeneratedColumn<int>(
    'model_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    registration,
    vin,
    manufacturer,
    model,
    engine,
    modelYear,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vehicle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('registration')) {
      context.handle(
        _registrationMeta,
        registration.isAcceptableOrUnknown(
          data['registration']!,
          _registrationMeta,
        ),
      );
    }
    if (data.containsKey('vin')) {
      context.handle(
        _vinMeta,
        vin.isAcceptableOrUnknown(data['vin']!, _vinMeta),
      );
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
        _manufacturerMeta,
        manufacturer.isAcceptableOrUnknown(
          data['manufacturer']!,
          _manufacturerMeta,
        ),
      );
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('engine')) {
      context.handle(
        _engineMeta,
        engine.isAcceptableOrUnknown(data['engine']!, _engineMeta),
      );
    }
    if (data.containsKey('model_year')) {
      context.handle(
        _modelYearMeta,
        modelYear.isAcceptableOrUnknown(data['model_year']!, _modelYearMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vehicle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vehicle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      registration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registration'],
      ),
      vin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vin'],
      ),
      manufacturer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer'],
      ),
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      ),
      engine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}engine'],
      ),
      modelYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}model_year'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VehiclesTable createAlias(String alias) {
    return $VehiclesTable(attachedDatabase, alias);
  }
}

class Vehicle extends DataClass implements Insertable<Vehicle> {
  final int id;
  final String name;
  final String? registration;
  final String? vin;
  final String? manufacturer;
  final String? model;
  final String? engine;
  final int? modelYear;
  final DateTime createdAt;
  const Vehicle({
    required this.id,
    required this.name,
    this.registration,
    this.vin,
    this.manufacturer,
    this.model,
    this.engine,
    this.modelYear,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || registration != null) {
      map['registration'] = Variable<String>(registration);
    }
    if (!nullToAbsent || vin != null) {
      map['vin'] = Variable<String>(vin);
    }
    if (!nullToAbsent || manufacturer != null) {
      map['manufacturer'] = Variable<String>(manufacturer);
    }
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    if (!nullToAbsent || engine != null) {
      map['engine'] = Variable<String>(engine);
    }
    if (!nullToAbsent || modelYear != null) {
      map['model_year'] = Variable<int>(modelYear);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VehiclesCompanion toCompanion(bool nullToAbsent) {
    return VehiclesCompanion(
      id: Value(id),
      name: Value(name),
      registration: registration == null && nullToAbsent
          ? const Value.absent()
          : Value(registration),
      vin: vin == null && nullToAbsent ? const Value.absent() : Value(vin),
      manufacturer: manufacturer == null && nullToAbsent
          ? const Value.absent()
          : Value(manufacturer),
      model: model == null && nullToAbsent
          ? const Value.absent()
          : Value(model),
      engine: engine == null && nullToAbsent
          ? const Value.absent()
          : Value(engine),
      modelYear: modelYear == null && nullToAbsent
          ? const Value.absent()
          : Value(modelYear),
      createdAt: Value(createdAt),
    );
  }

  factory Vehicle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vehicle(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      registration: serializer.fromJson<String?>(json['registration']),
      vin: serializer.fromJson<String?>(json['vin']),
      manufacturer: serializer.fromJson<String?>(json['manufacturer']),
      model: serializer.fromJson<String?>(json['model']),
      engine: serializer.fromJson<String?>(json['engine']),
      modelYear: serializer.fromJson<int?>(json['modelYear']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'registration': serializer.toJson<String?>(registration),
      'vin': serializer.toJson<String?>(vin),
      'manufacturer': serializer.toJson<String?>(manufacturer),
      'model': serializer.toJson<String?>(model),
      'engine': serializer.toJson<String?>(engine),
      'modelYear': serializer.toJson<int?>(modelYear),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Vehicle copyWith({
    int? id,
    String? name,
    Value<String?> registration = const Value.absent(),
    Value<String?> vin = const Value.absent(),
    Value<String?> manufacturer = const Value.absent(),
    Value<String?> model = const Value.absent(),
    Value<String?> engine = const Value.absent(),
    Value<int?> modelYear = const Value.absent(),
    DateTime? createdAt,
  }) => Vehicle(
    id: id ?? this.id,
    name: name ?? this.name,
    registration: registration.present ? registration.value : this.registration,
    vin: vin.present ? vin.value : this.vin,
    manufacturer: manufacturer.present ? manufacturer.value : this.manufacturer,
    model: model.present ? model.value : this.model,
    engine: engine.present ? engine.value : this.engine,
    modelYear: modelYear.present ? modelYear.value : this.modelYear,
    createdAt: createdAt ?? this.createdAt,
  );
  Vehicle copyWithCompanion(VehiclesCompanion data) {
    return Vehicle(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      registration: data.registration.present
          ? data.registration.value
          : this.registration,
      vin: data.vin.present ? data.vin.value : this.vin,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      model: data.model.present ? data.model.value : this.model,
      engine: data.engine.present ? data.engine.value : this.engine,
      modelYear: data.modelYear.present ? data.modelYear.value : this.modelYear,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vehicle(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('registration: $registration, ')
          ..write('vin: $vin, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('model: $model, ')
          ..write('engine: $engine, ')
          ..write('modelYear: $modelYear, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    registration,
    vin,
    manufacturer,
    model,
    engine,
    modelYear,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vehicle &&
          other.id == this.id &&
          other.name == this.name &&
          other.registration == this.registration &&
          other.vin == this.vin &&
          other.manufacturer == this.manufacturer &&
          other.model == this.model &&
          other.engine == this.engine &&
          other.modelYear == this.modelYear &&
          other.createdAt == this.createdAt);
}

class VehiclesCompanion extends UpdateCompanion<Vehicle> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> registration;
  final Value<String?> vin;
  final Value<String?> manufacturer;
  final Value<String?> model;
  final Value<String?> engine;
  final Value<int?> modelYear;
  final Value<DateTime> createdAt;
  const VehiclesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.registration = const Value.absent(),
    this.vin = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.model = const Value.absent(),
    this.engine = const Value.absent(),
    this.modelYear = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  VehiclesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.registration = const Value.absent(),
    this.vin = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.model = const Value.absent(),
    this.engine = const Value.absent(),
    this.modelYear = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Vehicle> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? registration,
    Expression<String>? vin,
    Expression<String>? manufacturer,
    Expression<String>? model,
    Expression<String>? engine,
    Expression<int>? modelYear,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (registration != null) 'registration': registration,
      if (vin != null) 'vin': vin,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (model != null) 'model': model,
      if (engine != null) 'engine': engine,
      if (modelYear != null) 'model_year': modelYear,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  VehiclesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? registration,
    Value<String?>? vin,
    Value<String?>? manufacturer,
    Value<String?>? model,
    Value<String?>? engine,
    Value<int?>? modelYear,
    Value<DateTime>? createdAt,
  }) {
    return VehiclesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      registration: registration ?? this.registration,
      vin: vin ?? this.vin,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      engine: engine ?? this.engine,
      modelYear: modelYear ?? this.modelYear,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (registration.present) {
      map['registration'] = Variable<String>(registration.value);
    }
    if (vin.present) {
      map['vin'] = Variable<String>(vin.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (engine.present) {
      map['engine'] = Variable<String>(engine.value);
    }
    if (modelYear.present) {
      map['model_year'] = Variable<int>(modelYear.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('registration: $registration, ')
          ..write('vin: $vin, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('model: $model, ')
          ..write('engine: $engine, ')
          ..write('modelYear: $modelYear, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ScansTable extends Scans with TableInfo<$ScansTable, Scan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
    'vehicle_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
    'time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _simulatedMeta = const VerificationMeta(
    'simulated',
  );
  @override
  late final GeneratedColumn<bool> simulated = GeneratedColumn<bool>(
    'simulated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("simulated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _vinMeta = const VerificationMeta('vin');
  @override
  late final GeneratedColumn<String> vin = GeneratedColumn<String>(
    'vin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _protocolMeta = const VerificationMeta(
    'protocol',
  );
  @override
  late final GeneratedColumn<String> protocol = GeneratedColumn<String>(
    'protocol',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _adapterMeta = const VerificationMeta(
    'adapter',
  );
  @override
  late final GeneratedColumn<String> adapter = GeneratedColumn<String>(
    'adapter',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batteryVoltsMeta = const VerificationMeta(
    'batteryVolts',
  );
  @override
  late final GeneratedColumn<double> batteryVolts = GeneratedColumn<double>(
    'battery_volts',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _milOnMeta = const VerificationMeta('milOn');
  @override
  late final GeneratedColumn<bool> milOn = GeneratedColumn<bool>(
    'mil_on',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("mil_on" IN (0, 1))',
    ),
  );
  static const VerificationMeta _errorsMeta = const VerificationMeta('errors');
  @override
  late final GeneratedColumn<String> errors = GeneratedColumn<String>(
    'errors',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vehicleId,
    time,
    kind,
    simulated,
    vin,
    protocol,
    adapter,
    batteryVolts,
    milOn,
    errors,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scans';
  @override
  VerificationContext validateIntegrity(
    Insertable<Scan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('simulated')) {
      context.handle(
        _simulatedMeta,
        simulated.isAcceptableOrUnknown(data['simulated']!, _simulatedMeta),
      );
    }
    if (data.containsKey('vin')) {
      context.handle(
        _vinMeta,
        vin.isAcceptableOrUnknown(data['vin']!, _vinMeta),
      );
    }
    if (data.containsKey('protocol')) {
      context.handle(
        _protocolMeta,
        protocol.isAcceptableOrUnknown(data['protocol']!, _protocolMeta),
      );
    }
    if (data.containsKey('adapter')) {
      context.handle(
        _adapterMeta,
        adapter.isAcceptableOrUnknown(data['adapter']!, _adapterMeta),
      );
    }
    if (data.containsKey('battery_volts')) {
      context.handle(
        _batteryVoltsMeta,
        batteryVolts.isAcceptableOrUnknown(
          data['battery_volts']!,
          _batteryVoltsMeta,
        ),
      );
    }
    if (data.containsKey('mil_on')) {
      context.handle(
        _milOnMeta,
        milOn.isAcceptableOrUnknown(data['mil_on']!, _milOnMeta),
      );
    }
    if (data.containsKey('errors')) {
      context.handle(
        _errorsMeta,
        errors.isAcceptableOrUnknown(data['errors']!, _errorsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Scan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Scan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      ),
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}time'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      simulated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}simulated'],
      )!,
      vin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vin'],
      ),
      protocol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}protocol'],
      ),
      adapter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adapter'],
      ),
      batteryVolts: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}battery_volts'],
      ),
      milOn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}mil_on'],
      ),
      errors: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}errors'],
      )!,
    );
  }

  @override
  $ScansTable createAlias(String alias) {
    return $ScansTable(attachedDatabase, alias);
  }
}

class Scan extends DataClass implements Insertable<Scan> {
  final int id;
  final int? vehicleId;
  final DateTime time;

  /// `quick` or `full`.
  final String kind;

  /// True when the scan came from the simulator. Simulated scans are never
  /// mixed into a real vehicle's history.
  final bool simulated;
  final String? vin;
  final String? protocol;
  final String? adapter;
  final double? batteryVolts;
  final bool? milOn;

  /// JSON list of steps that failed during the scan.
  final String errors;
  const Scan({
    required this.id,
    this.vehicleId,
    required this.time,
    required this.kind,
    required this.simulated,
    this.vin,
    this.protocol,
    this.adapter,
    this.batteryVolts,
    this.milOn,
    required this.errors,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || vehicleId != null) {
      map['vehicle_id'] = Variable<int>(vehicleId);
    }
    map['time'] = Variable<DateTime>(time);
    map['kind'] = Variable<String>(kind);
    map['simulated'] = Variable<bool>(simulated);
    if (!nullToAbsent || vin != null) {
      map['vin'] = Variable<String>(vin);
    }
    if (!nullToAbsent || protocol != null) {
      map['protocol'] = Variable<String>(protocol);
    }
    if (!nullToAbsent || adapter != null) {
      map['adapter'] = Variable<String>(adapter);
    }
    if (!nullToAbsent || batteryVolts != null) {
      map['battery_volts'] = Variable<double>(batteryVolts);
    }
    if (!nullToAbsent || milOn != null) {
      map['mil_on'] = Variable<bool>(milOn);
    }
    map['errors'] = Variable<String>(errors);
    return map;
  }

  ScansCompanion toCompanion(bool nullToAbsent) {
    return ScansCompanion(
      id: Value(id),
      vehicleId: vehicleId == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleId),
      time: Value(time),
      kind: Value(kind),
      simulated: Value(simulated),
      vin: vin == null && nullToAbsent ? const Value.absent() : Value(vin),
      protocol: protocol == null && nullToAbsent
          ? const Value.absent()
          : Value(protocol),
      adapter: adapter == null && nullToAbsent
          ? const Value.absent()
          : Value(adapter),
      batteryVolts: batteryVolts == null && nullToAbsent
          ? const Value.absent()
          : Value(batteryVolts),
      milOn: milOn == null && nullToAbsent
          ? const Value.absent()
          : Value(milOn),
      errors: Value(errors),
    );
  }

  factory Scan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Scan(
      id: serializer.fromJson<int>(json['id']),
      vehicleId: serializer.fromJson<int?>(json['vehicleId']),
      time: serializer.fromJson<DateTime>(json['time']),
      kind: serializer.fromJson<String>(json['kind']),
      simulated: serializer.fromJson<bool>(json['simulated']),
      vin: serializer.fromJson<String?>(json['vin']),
      protocol: serializer.fromJson<String?>(json['protocol']),
      adapter: serializer.fromJson<String?>(json['adapter']),
      batteryVolts: serializer.fromJson<double?>(json['batteryVolts']),
      milOn: serializer.fromJson<bool?>(json['milOn']),
      errors: serializer.fromJson<String>(json['errors']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vehicleId': serializer.toJson<int?>(vehicleId),
      'time': serializer.toJson<DateTime>(time),
      'kind': serializer.toJson<String>(kind),
      'simulated': serializer.toJson<bool>(simulated),
      'vin': serializer.toJson<String?>(vin),
      'protocol': serializer.toJson<String?>(protocol),
      'adapter': serializer.toJson<String?>(adapter),
      'batteryVolts': serializer.toJson<double?>(batteryVolts),
      'milOn': serializer.toJson<bool?>(milOn),
      'errors': serializer.toJson<String>(errors),
    };
  }

  Scan copyWith({
    int? id,
    Value<int?> vehicleId = const Value.absent(),
    DateTime? time,
    String? kind,
    bool? simulated,
    Value<String?> vin = const Value.absent(),
    Value<String?> protocol = const Value.absent(),
    Value<String?> adapter = const Value.absent(),
    Value<double?> batteryVolts = const Value.absent(),
    Value<bool?> milOn = const Value.absent(),
    String? errors,
  }) => Scan(
    id: id ?? this.id,
    vehicleId: vehicleId.present ? vehicleId.value : this.vehicleId,
    time: time ?? this.time,
    kind: kind ?? this.kind,
    simulated: simulated ?? this.simulated,
    vin: vin.present ? vin.value : this.vin,
    protocol: protocol.present ? protocol.value : this.protocol,
    adapter: adapter.present ? adapter.value : this.adapter,
    batteryVolts: batteryVolts.present ? batteryVolts.value : this.batteryVolts,
    milOn: milOn.present ? milOn.value : this.milOn,
    errors: errors ?? this.errors,
  );
  Scan copyWithCompanion(ScansCompanion data) {
    return Scan(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      time: data.time.present ? data.time.value : this.time,
      kind: data.kind.present ? data.kind.value : this.kind,
      simulated: data.simulated.present ? data.simulated.value : this.simulated,
      vin: data.vin.present ? data.vin.value : this.vin,
      protocol: data.protocol.present ? data.protocol.value : this.protocol,
      adapter: data.adapter.present ? data.adapter.value : this.adapter,
      batteryVolts: data.batteryVolts.present
          ? data.batteryVolts.value
          : this.batteryVolts,
      milOn: data.milOn.present ? data.milOn.value : this.milOn,
      errors: data.errors.present ? data.errors.value : this.errors,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Scan(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('time: $time, ')
          ..write('kind: $kind, ')
          ..write('simulated: $simulated, ')
          ..write('vin: $vin, ')
          ..write('protocol: $protocol, ')
          ..write('adapter: $adapter, ')
          ..write('batteryVolts: $batteryVolts, ')
          ..write('milOn: $milOn, ')
          ..write('errors: $errors')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vehicleId,
    time,
    kind,
    simulated,
    vin,
    protocol,
    adapter,
    batteryVolts,
    milOn,
    errors,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Scan &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.time == this.time &&
          other.kind == this.kind &&
          other.simulated == this.simulated &&
          other.vin == this.vin &&
          other.protocol == this.protocol &&
          other.adapter == this.adapter &&
          other.batteryVolts == this.batteryVolts &&
          other.milOn == this.milOn &&
          other.errors == this.errors);
}

class ScansCompanion extends UpdateCompanion<Scan> {
  final Value<int> id;
  final Value<int?> vehicleId;
  final Value<DateTime> time;
  final Value<String> kind;
  final Value<bool> simulated;
  final Value<String?> vin;
  final Value<String?> protocol;
  final Value<String?> adapter;
  final Value<double?> batteryVolts;
  final Value<bool?> milOn;
  final Value<String> errors;
  const ScansCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.time = const Value.absent(),
    this.kind = const Value.absent(),
    this.simulated = const Value.absent(),
    this.vin = const Value.absent(),
    this.protocol = const Value.absent(),
    this.adapter = const Value.absent(),
    this.batteryVolts = const Value.absent(),
    this.milOn = const Value.absent(),
    this.errors = const Value.absent(),
  });
  ScansCompanion.insert({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    required DateTime time,
    required String kind,
    this.simulated = const Value.absent(),
    this.vin = const Value.absent(),
    this.protocol = const Value.absent(),
    this.adapter = const Value.absent(),
    this.batteryVolts = const Value.absent(),
    this.milOn = const Value.absent(),
    this.errors = const Value.absent(),
  }) : time = Value(time),
       kind = Value(kind);
  static Insertable<Scan> custom({
    Expression<int>? id,
    Expression<int>? vehicleId,
    Expression<DateTime>? time,
    Expression<String>? kind,
    Expression<bool>? simulated,
    Expression<String>? vin,
    Expression<String>? protocol,
    Expression<String>? adapter,
    Expression<double>? batteryVolts,
    Expression<bool>? milOn,
    Expression<String>? errors,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (time != null) 'time': time,
      if (kind != null) 'kind': kind,
      if (simulated != null) 'simulated': simulated,
      if (vin != null) 'vin': vin,
      if (protocol != null) 'protocol': protocol,
      if (adapter != null) 'adapter': adapter,
      if (batteryVolts != null) 'battery_volts': batteryVolts,
      if (milOn != null) 'mil_on': milOn,
      if (errors != null) 'errors': errors,
    });
  }

  ScansCompanion copyWith({
    Value<int>? id,
    Value<int?>? vehicleId,
    Value<DateTime>? time,
    Value<String>? kind,
    Value<bool>? simulated,
    Value<String?>? vin,
    Value<String?>? protocol,
    Value<String?>? adapter,
    Value<double?>? batteryVolts,
    Value<bool?>? milOn,
    Value<String>? errors,
  }) {
    return ScansCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      time: time ?? this.time,
      kind: kind ?? this.kind,
      simulated: simulated ?? this.simulated,
      vin: vin ?? this.vin,
      protocol: protocol ?? this.protocol,
      adapter: adapter ?? this.adapter,
      batteryVolts: batteryVolts ?? this.batteryVolts,
      milOn: milOn ?? this.milOn,
      errors: errors ?? this.errors,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (simulated.present) {
      map['simulated'] = Variable<bool>(simulated.value);
    }
    if (vin.present) {
      map['vin'] = Variable<String>(vin.value);
    }
    if (protocol.present) {
      map['protocol'] = Variable<String>(protocol.value);
    }
    if (adapter.present) {
      map['adapter'] = Variable<String>(adapter.value);
    }
    if (batteryVolts.present) {
      map['battery_volts'] = Variable<double>(batteryVolts.value);
    }
    if (milOn.present) {
      map['mil_on'] = Variable<bool>(milOn.value);
    }
    if (errors.present) {
      map['errors'] = Variable<String>(errors.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScansCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('time: $time, ')
          ..write('kind: $kind, ')
          ..write('simulated: $simulated, ')
          ..write('vin: $vin, ')
          ..write('protocol: $protocol, ')
          ..write('adapter: $adapter, ')
          ..write('batteryVolts: $batteryVolts, ')
          ..write('milOn: $milOn, ')
          ..write('errors: $errors')
          ..write(')'))
        .toString();
  }
}

class $ScanDtcsTable extends ScanDtcs with TableInfo<$ScanDtcsTable, ScanDtc> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanDtcsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _scanIdMeta = const VerificationMeta('scanId');
  @override
  late final GeneratedColumn<int> scanId = GeneratedColumn<int>(
    'scan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES scans (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 5,
      maxTextLength: 5,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ecuMeta = const VerificationMeta('ecu');
  @override
  late final GeneratedColumn<String> ecu = GeneratedColumn<String>(
    'ecu',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, scanId, code, status, ecu];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_dtcs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScanDtc> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('scan_id')) {
      context.handle(
        _scanIdMeta,
        scanId.isAcceptableOrUnknown(data['scan_id']!, _scanIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scanIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('ecu')) {
      context.handle(
        _ecuMeta,
        ecu.isAcceptableOrUnknown(data['ecu']!, _ecuMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanDtc map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanDtc(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      scanId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scan_id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      ecu: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ecu'],
      ),
    );
  }

  @override
  $ScanDtcsTable createAlias(String alias) {
    return $ScanDtcsTable(attachedDatabase, alias);
  }
}

class ScanDtc extends DataClass implements Insertable<ScanDtc> {
  final int id;
  final int scanId;
  final String code;

  /// stored, pending, permanent or freezeFrame.
  final String status;
  final String? ecu;
  const ScanDtc({
    required this.id,
    required this.scanId,
    required this.code,
    required this.status,
    this.ecu,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['scan_id'] = Variable<int>(scanId);
    map['code'] = Variable<String>(code);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || ecu != null) {
      map['ecu'] = Variable<String>(ecu);
    }
    return map;
  }

  ScanDtcsCompanion toCompanion(bool nullToAbsent) {
    return ScanDtcsCompanion(
      id: Value(id),
      scanId: Value(scanId),
      code: Value(code),
      status: Value(status),
      ecu: ecu == null && nullToAbsent ? const Value.absent() : Value(ecu),
    );
  }

  factory ScanDtc.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanDtc(
      id: serializer.fromJson<int>(json['id']),
      scanId: serializer.fromJson<int>(json['scanId']),
      code: serializer.fromJson<String>(json['code']),
      status: serializer.fromJson<String>(json['status']),
      ecu: serializer.fromJson<String?>(json['ecu']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scanId': serializer.toJson<int>(scanId),
      'code': serializer.toJson<String>(code),
      'status': serializer.toJson<String>(status),
      'ecu': serializer.toJson<String?>(ecu),
    };
  }

  ScanDtc copyWith({
    int? id,
    int? scanId,
    String? code,
    String? status,
    Value<String?> ecu = const Value.absent(),
  }) => ScanDtc(
    id: id ?? this.id,
    scanId: scanId ?? this.scanId,
    code: code ?? this.code,
    status: status ?? this.status,
    ecu: ecu.present ? ecu.value : this.ecu,
  );
  ScanDtc copyWithCompanion(ScanDtcsCompanion data) {
    return ScanDtc(
      id: data.id.present ? data.id.value : this.id,
      scanId: data.scanId.present ? data.scanId.value : this.scanId,
      code: data.code.present ? data.code.value : this.code,
      status: data.status.present ? data.status.value : this.status,
      ecu: data.ecu.present ? data.ecu.value : this.ecu,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanDtc(')
          ..write('id: $id, ')
          ..write('scanId: $scanId, ')
          ..write('code: $code, ')
          ..write('status: $status, ')
          ..write('ecu: $ecu')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, scanId, code, status, ecu);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanDtc &&
          other.id == this.id &&
          other.scanId == this.scanId &&
          other.code == this.code &&
          other.status == this.status &&
          other.ecu == this.ecu);
}

class ScanDtcsCompanion extends UpdateCompanion<ScanDtc> {
  final Value<int> id;
  final Value<int> scanId;
  final Value<String> code;
  final Value<String> status;
  final Value<String?> ecu;
  const ScanDtcsCompanion({
    this.id = const Value.absent(),
    this.scanId = const Value.absent(),
    this.code = const Value.absent(),
    this.status = const Value.absent(),
    this.ecu = const Value.absent(),
  });
  ScanDtcsCompanion.insert({
    this.id = const Value.absent(),
    required int scanId,
    required String code,
    required String status,
    this.ecu = const Value.absent(),
  }) : scanId = Value(scanId),
       code = Value(code),
       status = Value(status);
  static Insertable<ScanDtc> custom({
    Expression<int>? id,
    Expression<int>? scanId,
    Expression<String>? code,
    Expression<String>? status,
    Expression<String>? ecu,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scanId != null) 'scan_id': scanId,
      if (code != null) 'code': code,
      if (status != null) 'status': status,
      if (ecu != null) 'ecu': ecu,
    });
  }

  ScanDtcsCompanion copyWith({
    Value<int>? id,
    Value<int>? scanId,
    Value<String>? code,
    Value<String>? status,
    Value<String?>? ecu,
  }) {
    return ScanDtcsCompanion(
      id: id ?? this.id,
      scanId: scanId ?? this.scanId,
      code: code ?? this.code,
      status: status ?? this.status,
      ecu: ecu ?? this.ecu,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scanId.present) {
      map['scan_id'] = Variable<int>(scanId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (ecu.present) {
      map['ecu'] = Variable<String>(ecu.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanDtcsCompanion(')
          ..write('id: $id, ')
          ..write('scanId: $scanId, ')
          ..write('code: $code, ')
          ..write('status: $status, ')
          ..write('ecu: $ecu')
          ..write(')'))
        .toString();
  }
}

class $ScanReadingsTable extends ScanReadings
    with TableInfo<$ScanReadingsTable, ScanReading> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _scanIdMeta = const VerificationMeta('scanId');
  @override
  late final GeneratedColumn<int> scanId = GeneratedColumn<int>(
    'scan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES scans (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pidMeta = const VerificationMeta('pid');
  @override
  late final GeneratedColumn<int> pid = GeneratedColumn<int>(
    'pid',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textValueMeta = const VerificationMeta(
    'textValue',
  );
  @override
  late final GeneratedColumn<String> textValue = GeneratedColumn<String>(
    'text_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scanId,
    source,
    pid,
    key,
    name,
    value,
    unit,
    textValue,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_readings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScanReading> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('scan_id')) {
      context.handle(
        _scanIdMeta,
        scanId.isAcceptableOrUnknown(data['scan_id']!, _scanIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scanIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('pid')) {
      context.handle(
        _pidMeta,
        pid.isAcceptableOrUnknown(data['pid']!, _pidMeta),
      );
    } else if (isInserting) {
      context.missing(_pidMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('text_value')) {
      context.handle(
        _textValueMeta,
        textValue.isAcceptableOrUnknown(data['text_value']!, _textValueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanReading map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanReading(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      scanId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scan_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      pid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pid'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      textValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_value'],
      ),
    );
  }

  @override
  $ScanReadingsTable createAlias(String alias) {
    return $ScanReadingsTable(attachedDatabase, alias);
  }
}

class ScanReading extends DataClass implements Insertable<ScanReading> {
  final int id;
  final int scanId;

  /// `snapshot` or `freezeFrame`.
  final String source;
  final int pid;
  final String key;
  final String name;
  final double? value;
  final String unit;
  final String? textValue;
  const ScanReading({
    required this.id,
    required this.scanId,
    required this.source,
    required this.pid,
    required this.key,
    required this.name,
    this.value,
    required this.unit,
    this.textValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['scan_id'] = Variable<int>(scanId);
    map['source'] = Variable<String>(source);
    map['pid'] = Variable<int>(pid);
    map['key'] = Variable<String>(key);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<double>(value);
    }
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || textValue != null) {
      map['text_value'] = Variable<String>(textValue);
    }
    return map;
  }

  ScanReadingsCompanion toCompanion(bool nullToAbsent) {
    return ScanReadingsCompanion(
      id: Value(id),
      scanId: Value(scanId),
      source: Value(source),
      pid: Value(pid),
      key: Value(key),
      name: Value(name),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
      unit: Value(unit),
      textValue: textValue == null && nullToAbsent
          ? const Value.absent()
          : Value(textValue),
    );
  }

  factory ScanReading.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanReading(
      id: serializer.fromJson<int>(json['id']),
      scanId: serializer.fromJson<int>(json['scanId']),
      source: serializer.fromJson<String>(json['source']),
      pid: serializer.fromJson<int>(json['pid']),
      key: serializer.fromJson<String>(json['key']),
      name: serializer.fromJson<String>(json['name']),
      value: serializer.fromJson<double?>(json['value']),
      unit: serializer.fromJson<String>(json['unit']),
      textValue: serializer.fromJson<String?>(json['textValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scanId': serializer.toJson<int>(scanId),
      'source': serializer.toJson<String>(source),
      'pid': serializer.toJson<int>(pid),
      'key': serializer.toJson<String>(key),
      'name': serializer.toJson<String>(name),
      'value': serializer.toJson<double?>(value),
      'unit': serializer.toJson<String>(unit),
      'textValue': serializer.toJson<String?>(textValue),
    };
  }

  ScanReading copyWith({
    int? id,
    int? scanId,
    String? source,
    int? pid,
    String? key,
    String? name,
    Value<double?> value = const Value.absent(),
    String? unit,
    Value<String?> textValue = const Value.absent(),
  }) => ScanReading(
    id: id ?? this.id,
    scanId: scanId ?? this.scanId,
    source: source ?? this.source,
    pid: pid ?? this.pid,
    key: key ?? this.key,
    name: name ?? this.name,
    value: value.present ? value.value : this.value,
    unit: unit ?? this.unit,
    textValue: textValue.present ? textValue.value : this.textValue,
  );
  ScanReading copyWithCompanion(ScanReadingsCompanion data) {
    return ScanReading(
      id: data.id.present ? data.id.value : this.id,
      scanId: data.scanId.present ? data.scanId.value : this.scanId,
      source: data.source.present ? data.source.value : this.source,
      pid: data.pid.present ? data.pid.value : this.pid,
      key: data.key.present ? data.key.value : this.key,
      name: data.name.present ? data.name.value : this.name,
      value: data.value.present ? data.value.value : this.value,
      unit: data.unit.present ? data.unit.value : this.unit,
      textValue: data.textValue.present ? data.textValue.value : this.textValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanReading(')
          ..write('id: $id, ')
          ..write('scanId: $scanId, ')
          ..write('source: $source, ')
          ..write('pid: $pid, ')
          ..write('key: $key, ')
          ..write('name: $name, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('textValue: $textValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, scanId, source, pid, key, name, value, unit, textValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanReading &&
          other.id == this.id &&
          other.scanId == this.scanId &&
          other.source == this.source &&
          other.pid == this.pid &&
          other.key == this.key &&
          other.name == this.name &&
          other.value == this.value &&
          other.unit == this.unit &&
          other.textValue == this.textValue);
}

class ScanReadingsCompanion extends UpdateCompanion<ScanReading> {
  final Value<int> id;
  final Value<int> scanId;
  final Value<String> source;
  final Value<int> pid;
  final Value<String> key;
  final Value<String> name;
  final Value<double?> value;
  final Value<String> unit;
  final Value<String?> textValue;
  const ScanReadingsCompanion({
    this.id = const Value.absent(),
    this.scanId = const Value.absent(),
    this.source = const Value.absent(),
    this.pid = const Value.absent(),
    this.key = const Value.absent(),
    this.name = const Value.absent(),
    this.value = const Value.absent(),
    this.unit = const Value.absent(),
    this.textValue = const Value.absent(),
  });
  ScanReadingsCompanion.insert({
    this.id = const Value.absent(),
    required int scanId,
    required String source,
    required int pid,
    required String key,
    required String name,
    this.value = const Value.absent(),
    required String unit,
    this.textValue = const Value.absent(),
  }) : scanId = Value(scanId),
       source = Value(source),
       pid = Value(pid),
       key = Value(key),
       name = Value(name),
       unit = Value(unit);
  static Insertable<ScanReading> custom({
    Expression<int>? id,
    Expression<int>? scanId,
    Expression<String>? source,
    Expression<int>? pid,
    Expression<String>? key,
    Expression<String>? name,
    Expression<double>? value,
    Expression<String>? unit,
    Expression<String>? textValue,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scanId != null) 'scan_id': scanId,
      if (source != null) 'source': source,
      if (pid != null) 'pid': pid,
      if (key != null) 'key': key,
      if (name != null) 'name': name,
      if (value != null) 'value': value,
      if (unit != null) 'unit': unit,
      if (textValue != null) 'text_value': textValue,
    });
  }

  ScanReadingsCompanion copyWith({
    Value<int>? id,
    Value<int>? scanId,
    Value<String>? source,
    Value<int>? pid,
    Value<String>? key,
    Value<String>? name,
    Value<double?>? value,
    Value<String>? unit,
    Value<String?>? textValue,
  }) {
    return ScanReadingsCompanion(
      id: id ?? this.id,
      scanId: scanId ?? this.scanId,
      source: source ?? this.source,
      pid: pid ?? this.pid,
      key: key ?? this.key,
      name: name ?? this.name,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      textValue: textValue ?? this.textValue,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scanId.present) {
      map['scan_id'] = Variable<int>(scanId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (pid.present) {
      map['pid'] = Variable<int>(pid.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (textValue.present) {
      map['text_value'] = Variable<String>(textValue.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanReadingsCompanion(')
          ..write('id: $id, ')
          ..write('scanId: $scanId, ')
          ..write('source: $source, ')
          ..write('pid: $pid, ')
          ..write('key: $key, ')
          ..write('name: $name, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('textValue: $textValue')
          ..write(')'))
        .toString();
  }
}

class $ScanMonitorsTable extends ScanMonitors
    with TableInfo<$ScanMonitorsTable, ScanMonitor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanMonitorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _scanIdMeta = const VerificationMeta('scanId');
  @override
  late final GeneratedColumn<int> scanId = GeneratedColumn<int>(
    'scan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES scans (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, scanId, key, name, state];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_monitors';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScanMonitor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('scan_id')) {
      context.handle(
        _scanIdMeta,
        scanId.isAcceptableOrUnknown(data['scan_id']!, _scanIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scanIdMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanMonitor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanMonitor(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      scanId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scan_id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
    );
  }

  @override
  $ScanMonitorsTable createAlias(String alias) {
    return $ScanMonitorsTable(attachedDatabase, alias);
  }
}

class ScanMonitor extends DataClass implements Insertable<ScanMonitor> {
  final int id;
  final int scanId;
  final String key;
  final String name;

  /// complete or incomplete (unsupported monitors are not stored).
  final String state;
  const ScanMonitor({
    required this.id,
    required this.scanId,
    required this.key,
    required this.name,
    required this.state,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['scan_id'] = Variable<int>(scanId);
    map['key'] = Variable<String>(key);
    map['name'] = Variable<String>(name);
    map['state'] = Variable<String>(state);
    return map;
  }

  ScanMonitorsCompanion toCompanion(bool nullToAbsent) {
    return ScanMonitorsCompanion(
      id: Value(id),
      scanId: Value(scanId),
      key: Value(key),
      name: Value(name),
      state: Value(state),
    );
  }

  factory ScanMonitor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanMonitor(
      id: serializer.fromJson<int>(json['id']),
      scanId: serializer.fromJson<int>(json['scanId']),
      key: serializer.fromJson<String>(json['key']),
      name: serializer.fromJson<String>(json['name']),
      state: serializer.fromJson<String>(json['state']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scanId': serializer.toJson<int>(scanId),
      'key': serializer.toJson<String>(key),
      'name': serializer.toJson<String>(name),
      'state': serializer.toJson<String>(state),
    };
  }

  ScanMonitor copyWith({
    int? id,
    int? scanId,
    String? key,
    String? name,
    String? state,
  }) => ScanMonitor(
    id: id ?? this.id,
    scanId: scanId ?? this.scanId,
    key: key ?? this.key,
    name: name ?? this.name,
    state: state ?? this.state,
  );
  ScanMonitor copyWithCompanion(ScanMonitorsCompanion data) {
    return ScanMonitor(
      id: data.id.present ? data.id.value : this.id,
      scanId: data.scanId.present ? data.scanId.value : this.scanId,
      key: data.key.present ? data.key.value : this.key,
      name: data.name.present ? data.name.value : this.name,
      state: data.state.present ? data.state.value : this.state,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanMonitor(')
          ..write('id: $id, ')
          ..write('scanId: $scanId, ')
          ..write('key: $key, ')
          ..write('name: $name, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, scanId, key, name, state);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanMonitor &&
          other.id == this.id &&
          other.scanId == this.scanId &&
          other.key == this.key &&
          other.name == this.name &&
          other.state == this.state);
}

class ScanMonitorsCompanion extends UpdateCompanion<ScanMonitor> {
  final Value<int> id;
  final Value<int> scanId;
  final Value<String> key;
  final Value<String> name;
  final Value<String> state;
  const ScanMonitorsCompanion({
    this.id = const Value.absent(),
    this.scanId = const Value.absent(),
    this.key = const Value.absent(),
    this.name = const Value.absent(),
    this.state = const Value.absent(),
  });
  ScanMonitorsCompanion.insert({
    this.id = const Value.absent(),
    required int scanId,
    required String key,
    required String name,
    required String state,
  }) : scanId = Value(scanId),
       key = Value(key),
       name = Value(name),
       state = Value(state);
  static Insertable<ScanMonitor> custom({
    Expression<int>? id,
    Expression<int>? scanId,
    Expression<String>? key,
    Expression<String>? name,
    Expression<String>? state,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scanId != null) 'scan_id': scanId,
      if (key != null) 'key': key,
      if (name != null) 'name': name,
      if (state != null) 'state': state,
    });
  }

  ScanMonitorsCompanion copyWith({
    Value<int>? id,
    Value<int>? scanId,
    Value<String>? key,
    Value<String>? name,
    Value<String>? state,
  }) {
    return ScanMonitorsCompanion(
      id: id ?? this.id,
      scanId: scanId ?? this.scanId,
      key: key ?? this.key,
      name: name ?? this.name,
      state: state ?? this.state,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scanId.present) {
      map['scan_id'] = Variable<int>(scanId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanMonitorsCompanion(')
          ..write('id: $id, ')
          ..write('scanId: $scanId, ')
          ..write('key: $key, ')
          ..write('name: $name, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }
}

class $MaintenanceNotesTable extends MaintenanceNotes
    with TableInfo<$MaintenanceNotesTable, MaintenanceNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaintenanceNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
    'time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 4000,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, vehicleId, time, body];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'maintenance_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<MaintenanceNote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MaintenanceNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaintenanceNote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      )!,
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}time'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
    );
  }

  @override
  $MaintenanceNotesTable createAlias(String alias) {
    return $MaintenanceNotesTable(attachedDatabase, alias);
  }
}

class MaintenanceNote extends DataClass implements Insertable<MaintenanceNote> {
  final int id;
  final int vehicleId;
  final DateTime time;
  final String body;
  const MaintenanceNote({
    required this.id,
    required this.vehicleId,
    required this.time,
    required this.body,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vehicle_id'] = Variable<int>(vehicleId);
    map['time'] = Variable<DateTime>(time);
    map['body'] = Variable<String>(body);
    return map;
  }

  MaintenanceNotesCompanion toCompanion(bool nullToAbsent) {
    return MaintenanceNotesCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      time: Value(time),
      body: Value(body),
    );
  }

  factory MaintenanceNote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaintenanceNote(
      id: serializer.fromJson<int>(json['id']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      time: serializer.fromJson<DateTime>(json['time']),
      body: serializer.fromJson<String>(json['body']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'time': serializer.toJson<DateTime>(time),
      'body': serializer.toJson<String>(body),
    };
  }

  MaintenanceNote copyWith({
    int? id,
    int? vehicleId,
    DateTime? time,
    String? body,
  }) => MaintenanceNote(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    time: time ?? this.time,
    body: body ?? this.body,
  );
  MaintenanceNote copyWithCompanion(MaintenanceNotesCompanion data) {
    return MaintenanceNote(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      time: data.time.present ? data.time.value : this.time,
      body: data.body.present ? data.body.value : this.body,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceNote(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('time: $time, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, vehicleId, time, body);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaintenanceNote &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.time == this.time &&
          other.body == this.body);
}

class MaintenanceNotesCompanion extends UpdateCompanion<MaintenanceNote> {
  final Value<int> id;
  final Value<int> vehicleId;
  final Value<DateTime> time;
  final Value<String> body;
  const MaintenanceNotesCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.time = const Value.absent(),
    this.body = const Value.absent(),
  });
  MaintenanceNotesCompanion.insert({
    this.id = const Value.absent(),
    required int vehicleId,
    this.time = const Value.absent(),
    required String body,
  }) : vehicleId = Value(vehicleId),
       body = Value(body);
  static Insertable<MaintenanceNote> custom({
    Expression<int>? id,
    Expression<int>? vehicleId,
    Expression<DateTime>? time,
    Expression<String>? body,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (time != null) 'time': time,
      if (body != null) 'body': body,
    });
  }

  MaintenanceNotesCompanion copyWith({
    Value<int>? id,
    Value<int>? vehicleId,
    Value<DateTime>? time,
    Value<String>? body,
  }) {
    return MaintenanceNotesCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      time: time ?? this.time,
      body: body ?? this.body,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceNotesCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('time: $time, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }
}

class $AdapterProfilesTable extends AdapterProfiles
    with TableInfo<$AdapterProfilesTable, AdapterProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdapterProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _identityMeta = const VerificationMeta(
    'identity',
  );
  @override
  late final GeneratedColumn<String> identity = GeneratedColumn<String>(
    'identity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manufacturerMeta = const VerificationMeta(
    'manufacturer',
  );
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
    'manufacturer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capabilitiesMeta = const VerificationMeta(
    'capabilities',
  );
  @override
  late final GeneratedColumn<String> capabilities = GeneratedColumn<String>(
    'capabilities',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeenMeta = const VerificationMeta(
    'lastSeen',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeen = GeneratedColumn<DateTime>(
    'last_seen',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    address,
    kind,
    identity,
    manufacturer,
    capabilities,
    lastSeen,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'adapter_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdapterProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('identity')) {
      context.handle(
        _identityMeta,
        identity.isAcceptableOrUnknown(data['identity']!, _identityMeta),
      );
    } else if (isInserting) {
      context.missing(_identityMeta);
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
        _manufacturerMeta,
        manufacturer.isAcceptableOrUnknown(
          data['manufacturer']!,
          _manufacturerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_manufacturerMeta);
    }
    if (data.containsKey('capabilities')) {
      context.handle(
        _capabilitiesMeta,
        capabilities.isAcceptableOrUnknown(
          data['capabilities']!,
          _capabilitiesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_capabilitiesMeta);
    }
    if (data.containsKey('last_seen')) {
      context.handle(
        _lastSeenMeta,
        lastSeen.isAcceptableOrUnknown(data['last_seen']!, _lastSeenMeta),
      );
    } else if (isInserting) {
      context.missing(_lastSeenMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {address, kind};
  @override
  AdapterProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdapterProfile(
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      identity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}identity'],
      )!,
      manufacturer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer'],
      )!,
      capabilities: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}capabilities'],
      )!,
      lastSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen'],
      )!,
    );
  }

  @override
  $AdapterProfilesTable createAlias(String alias) {
    return $AdapterProfilesTable(attachedDatabase, alias);
  }
}

class AdapterProfile extends DataClass implements Insertable<AdapterProfile> {
  final String address;
  final String kind;
  final String identity;
  final String manufacturer;

  /// JSON map of capability key to supported.
  final String capabilities;
  final DateTime lastSeen;
  const AdapterProfile({
    required this.address,
    required this.kind,
    required this.identity,
    required this.manufacturer,
    required this.capabilities,
    required this.lastSeen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['address'] = Variable<String>(address);
    map['kind'] = Variable<String>(kind);
    map['identity'] = Variable<String>(identity);
    map['manufacturer'] = Variable<String>(manufacturer);
    map['capabilities'] = Variable<String>(capabilities);
    map['last_seen'] = Variable<DateTime>(lastSeen);
    return map;
  }

  AdapterProfilesCompanion toCompanion(bool nullToAbsent) {
    return AdapterProfilesCompanion(
      address: Value(address),
      kind: Value(kind),
      identity: Value(identity),
      manufacturer: Value(manufacturer),
      capabilities: Value(capabilities),
      lastSeen: Value(lastSeen),
    );
  }

  factory AdapterProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdapterProfile(
      address: serializer.fromJson<String>(json['address']),
      kind: serializer.fromJson<String>(json['kind']),
      identity: serializer.fromJson<String>(json['identity']),
      manufacturer: serializer.fromJson<String>(json['manufacturer']),
      capabilities: serializer.fromJson<String>(json['capabilities']),
      lastSeen: serializer.fromJson<DateTime>(json['lastSeen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'address': serializer.toJson<String>(address),
      'kind': serializer.toJson<String>(kind),
      'identity': serializer.toJson<String>(identity),
      'manufacturer': serializer.toJson<String>(manufacturer),
      'capabilities': serializer.toJson<String>(capabilities),
      'lastSeen': serializer.toJson<DateTime>(lastSeen),
    };
  }

  AdapterProfile copyWith({
    String? address,
    String? kind,
    String? identity,
    String? manufacturer,
    String? capabilities,
    DateTime? lastSeen,
  }) => AdapterProfile(
    address: address ?? this.address,
    kind: kind ?? this.kind,
    identity: identity ?? this.identity,
    manufacturer: manufacturer ?? this.manufacturer,
    capabilities: capabilities ?? this.capabilities,
    lastSeen: lastSeen ?? this.lastSeen,
  );
  AdapterProfile copyWithCompanion(AdapterProfilesCompanion data) {
    return AdapterProfile(
      address: data.address.present ? data.address.value : this.address,
      kind: data.kind.present ? data.kind.value : this.kind,
      identity: data.identity.present ? data.identity.value : this.identity,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      capabilities: data.capabilities.present
          ? data.capabilities.value
          : this.capabilities,
      lastSeen: data.lastSeen.present ? data.lastSeen.value : this.lastSeen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdapterProfile(')
          ..write('address: $address, ')
          ..write('kind: $kind, ')
          ..write('identity: $identity, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('capabilities: $capabilities, ')
          ..write('lastSeen: $lastSeen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    address,
    kind,
    identity,
    manufacturer,
    capabilities,
    lastSeen,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdapterProfile &&
          other.address == this.address &&
          other.kind == this.kind &&
          other.identity == this.identity &&
          other.manufacturer == this.manufacturer &&
          other.capabilities == this.capabilities &&
          other.lastSeen == this.lastSeen);
}

class AdapterProfilesCompanion extends UpdateCompanion<AdapterProfile> {
  final Value<String> address;
  final Value<String> kind;
  final Value<String> identity;
  final Value<String> manufacturer;
  final Value<String> capabilities;
  final Value<DateTime> lastSeen;
  final Value<int> rowid;
  const AdapterProfilesCompanion({
    this.address = const Value.absent(),
    this.kind = const Value.absent(),
    this.identity = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.capabilities = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AdapterProfilesCompanion.insert({
    required String address,
    required String kind,
    required String identity,
    required String manufacturer,
    required String capabilities,
    required DateTime lastSeen,
    this.rowid = const Value.absent(),
  }) : address = Value(address),
       kind = Value(kind),
       identity = Value(identity),
       manufacturer = Value(manufacturer),
       capabilities = Value(capabilities),
       lastSeen = Value(lastSeen);
  static Insertable<AdapterProfile> custom({
    Expression<String>? address,
    Expression<String>? kind,
    Expression<String>? identity,
    Expression<String>? manufacturer,
    Expression<String>? capabilities,
    Expression<DateTime>? lastSeen,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (address != null) 'address': address,
      if (kind != null) 'kind': kind,
      if (identity != null) 'identity': identity,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (capabilities != null) 'capabilities': capabilities,
      if (lastSeen != null) 'last_seen': lastSeen,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AdapterProfilesCompanion copyWith({
    Value<String>? address,
    Value<String>? kind,
    Value<String>? identity,
    Value<String>? manufacturer,
    Value<String>? capabilities,
    Value<DateTime>? lastSeen,
    Value<int>? rowid,
  }) {
    return AdapterProfilesCompanion(
      address: address ?? this.address,
      kind: kind ?? this.kind,
      identity: identity ?? this.identity,
      manufacturer: manufacturer ?? this.manufacturer,
      capabilities: capabilities ?? this.capabilities,
      lastSeen: lastSeen ?? this.lastSeen,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (identity.present) {
      map['identity'] = Variable<String>(identity.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (capabilities.present) {
      map['capabilities'] = Variable<String>(capabilities.value);
    }
    if (lastSeen.present) {
      map['last_seen'] = Variable<DateTime>(lastSeen.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdapterProfilesCompanion(')
          ..write('address: $address, ')
          ..write('kind: $kind, ')
          ..write('identity: $identity, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('capabilities: $capabilities, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DtcPacksTable extends DtcPacks with TableInfo<$DtcPacksTable, DtcPack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DtcPacksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _installedAtMeta = const VerificationMeta(
    'installedAt',
  );
  @override
  late final GeneratedColumn<DateTime> installedAt = GeneratedColumn<DateTime>(
    'installed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    version,
    source,
    scope,
    installedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dtc_packs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DtcPack> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('installed_at')) {
      context.handle(
        _installedAtMeta,
        installedAt.isAcceptableOrUnknown(
          data['installed_at']!,
          _installedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DtcPack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DtcPack(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      installedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}installed_at'],
      )!,
    );
  }

  @override
  $DtcPacksTable createAlias(String alias) {
    return $DtcPacksTable(attachedDatabase, alias);
  }
}

class DtcPack extends DataClass implements Insertable<DtcPack> {
  final String id;
  final String title;
  final String version;

  /// Who supplied the data and under what licence.
  final String source;

  /// `generic` (SAE) or a manufacturer name.
  final String scope;
  final DateTime installedAt;
  const DtcPack({
    required this.id,
    required this.title,
    required this.version,
    required this.source,
    required this.scope,
    required this.installedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['version'] = Variable<String>(version);
    map['source'] = Variable<String>(source);
    map['scope'] = Variable<String>(scope);
    map['installed_at'] = Variable<DateTime>(installedAt);
    return map;
  }

  DtcPacksCompanion toCompanion(bool nullToAbsent) {
    return DtcPacksCompanion(
      id: Value(id),
      title: Value(title),
      version: Value(version),
      source: Value(source),
      scope: Value(scope),
      installedAt: Value(installedAt),
    );
  }

  factory DtcPack.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DtcPack(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      version: serializer.fromJson<String>(json['version']),
      source: serializer.fromJson<String>(json['source']),
      scope: serializer.fromJson<String>(json['scope']),
      installedAt: serializer.fromJson<DateTime>(json['installedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'version': serializer.toJson<String>(version),
      'source': serializer.toJson<String>(source),
      'scope': serializer.toJson<String>(scope),
      'installedAt': serializer.toJson<DateTime>(installedAt),
    };
  }

  DtcPack copyWith({
    String? id,
    String? title,
    String? version,
    String? source,
    String? scope,
    DateTime? installedAt,
  }) => DtcPack(
    id: id ?? this.id,
    title: title ?? this.title,
    version: version ?? this.version,
    source: source ?? this.source,
    scope: scope ?? this.scope,
    installedAt: installedAt ?? this.installedAt,
  );
  DtcPack copyWithCompanion(DtcPacksCompanion data) {
    return DtcPack(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      version: data.version.present ? data.version.value : this.version,
      source: data.source.present ? data.source.value : this.source,
      scope: data.scope.present ? data.scope.value : this.scope,
      installedAt: data.installedAt.present
          ? data.installedAt.value
          : this.installedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DtcPack(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('version: $version, ')
          ..write('source: $source, ')
          ..write('scope: $scope, ')
          ..write('installedAt: $installedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, version, source, scope, installedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DtcPack &&
          other.id == this.id &&
          other.title == this.title &&
          other.version == this.version &&
          other.source == this.source &&
          other.scope == this.scope &&
          other.installedAt == this.installedAt);
}

class DtcPacksCompanion extends UpdateCompanion<DtcPack> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> version;
  final Value<String> source;
  final Value<String> scope;
  final Value<DateTime> installedAt;
  final Value<int> rowid;
  const DtcPacksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.version = const Value.absent(),
    this.source = const Value.absent(),
    this.scope = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DtcPacksCompanion.insert({
    required String id,
    required String title,
    required String version,
    required String source,
    required String scope,
    this.installedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       version = Value(version),
       source = Value(source),
       scope = Value(scope);
  static Insertable<DtcPack> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? version,
    Expression<String>? source,
    Expression<String>? scope,
    Expression<DateTime>? installedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (version != null) 'version': version,
      if (source != null) 'source': source,
      if (scope != null) 'scope': scope,
      if (installedAt != null) 'installed_at': installedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DtcPacksCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? version,
    Value<String>? source,
    Value<String>? scope,
    Value<DateTime>? installedAt,
    Value<int>? rowid,
  }) {
    return DtcPacksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      version: version ?? this.version,
      source: source ?? this.source,
      scope: scope ?? this.scope,
      installedAt: installedAt ?? this.installedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<DateTime>(installedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DtcPacksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('version: $version, ')
          ..write('source: $source, ')
          ..write('scope: $scope, ')
          ..write('installedAt: $installedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DtcDefinitionsTable extends DtcDefinitions
    with TableInfo<$DtcDefinitionsTable, DtcDefinition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DtcDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  @override
  late final GeneratedColumn<String> packId = GeneratedColumn<String>(
    'pack_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES dtc_packs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 5,
      maxTextLength: 5,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manufacturerMeta = const VerificationMeta(
    'manufacturer',
  );
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
    'manufacturer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _causesMeta = const VerificationMeta('causes');
  @override
  late final GeneratedColumn<String> causes = GeneratedColumn<String>(
    'causes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _symptomsMeta = const VerificationMeta(
    'symptoms',
  );
  @override
  late final GeneratedColumn<String> symptoms = GeneratedColumn<String>(
    'symptoms',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _inspectionMeta = const VerificationMeta(
    'inspection',
  );
  @override
  late final GeneratedColumn<String> inspection = GeneratedColumn<String>(
    'inspection',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _repairsMeta = const VerificationMeta(
    'repairs',
  );
  @override
  late final GeneratedColumn<String> repairs = GeneratedColumn<String>(
    'repairs',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _componentsMeta = const VerificationMeta(
    'components',
  );
  @override
  late final GeneratedColumn<String> components = GeneratedColumn<String>(
    'components',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<String> confidence = GeneratedColumn<String>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    packId,
    code,
    manufacturer,
    description,
    category,
    severity,
    causes,
    symptoms,
    inspection,
    repairs,
    components,
    confidence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dtc_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<DtcDefinition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pack_id')) {
      context.handle(
        _packIdMeta,
        packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
        _manufacturerMeta,
        manufacturer.isAcceptableOrUnknown(
          data['manufacturer']!,
          _manufacturerMeta,
        ),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    }
    if (data.containsKey('causes')) {
      context.handle(
        _causesMeta,
        causes.isAcceptableOrUnknown(data['causes']!, _causesMeta),
      );
    }
    if (data.containsKey('symptoms')) {
      context.handle(
        _symptomsMeta,
        symptoms.isAcceptableOrUnknown(data['symptoms']!, _symptomsMeta),
      );
    }
    if (data.containsKey('inspection')) {
      context.handle(
        _inspectionMeta,
        inspection.isAcceptableOrUnknown(data['inspection']!, _inspectionMeta),
      );
    }
    if (data.containsKey('repairs')) {
      context.handle(
        _repairsMeta,
        repairs.isAcceptableOrUnknown(data['repairs']!, _repairsMeta),
      );
    }
    if (data.containsKey('components')) {
      context.handle(
        _componentsMeta,
        components.isAcceptableOrUnknown(data['components']!, _componentsMeta),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {packId, code};
  @override
  DtcDefinition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DtcDefinition(
      packId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      manufacturer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      ),
      causes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}causes'],
      )!,
      symptoms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symptoms'],
      )!,
      inspection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inspection'],
      )!,
      repairs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repairs'],
      )!,
      components: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}components'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confidence'],
      )!,
    );
  }

  @override
  $DtcDefinitionsTable createAlias(String alias) {
    return $DtcDefinitionsTable(attachedDatabase, alias);
  }
}

class DtcDefinition extends DataClass implements Insertable<DtcDefinition> {
  final String packId;
  final String code;

  /// Null for generic definitions; otherwise the manufacturer it applies to.
  final String? manufacturer;
  final String description;
  final String? category;

  /// critical, high, medium, low or informational.
  final String? severity;

  /// JSON lists.
  final String causes;
  final String symptoms;
  final String inspection;
  final String repairs;
  final String components;

  /// `verified` (manufacturer data) or `generic`.
  final String confidence;
  const DtcDefinition({
    required this.packId,
    required this.code,
    this.manufacturer,
    required this.description,
    this.category,
    this.severity,
    required this.causes,
    required this.symptoms,
    required this.inspection,
    required this.repairs,
    required this.components,
    required this.confidence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pack_id'] = Variable<String>(packId);
    map['code'] = Variable<String>(code);
    if (!nullToAbsent || manufacturer != null) {
      map['manufacturer'] = Variable<String>(manufacturer);
    }
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || severity != null) {
      map['severity'] = Variable<String>(severity);
    }
    map['causes'] = Variable<String>(causes);
    map['symptoms'] = Variable<String>(symptoms);
    map['inspection'] = Variable<String>(inspection);
    map['repairs'] = Variable<String>(repairs);
    map['components'] = Variable<String>(components);
    map['confidence'] = Variable<String>(confidence);
    return map;
  }

  DtcDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return DtcDefinitionsCompanion(
      packId: Value(packId),
      code: Value(code),
      manufacturer: manufacturer == null && nullToAbsent
          ? const Value.absent()
          : Value(manufacturer),
      description: Value(description),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      severity: severity == null && nullToAbsent
          ? const Value.absent()
          : Value(severity),
      causes: Value(causes),
      symptoms: Value(symptoms),
      inspection: Value(inspection),
      repairs: Value(repairs),
      components: Value(components),
      confidence: Value(confidence),
    );
  }

  factory DtcDefinition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DtcDefinition(
      packId: serializer.fromJson<String>(json['packId']),
      code: serializer.fromJson<String>(json['code']),
      manufacturer: serializer.fromJson<String?>(json['manufacturer']),
      description: serializer.fromJson<String>(json['description']),
      category: serializer.fromJson<String?>(json['category']),
      severity: serializer.fromJson<String?>(json['severity']),
      causes: serializer.fromJson<String>(json['causes']),
      symptoms: serializer.fromJson<String>(json['symptoms']),
      inspection: serializer.fromJson<String>(json['inspection']),
      repairs: serializer.fromJson<String>(json['repairs']),
      components: serializer.fromJson<String>(json['components']),
      confidence: serializer.fromJson<String>(json['confidence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'packId': serializer.toJson<String>(packId),
      'code': serializer.toJson<String>(code),
      'manufacturer': serializer.toJson<String?>(manufacturer),
      'description': serializer.toJson<String>(description),
      'category': serializer.toJson<String?>(category),
      'severity': serializer.toJson<String?>(severity),
      'causes': serializer.toJson<String>(causes),
      'symptoms': serializer.toJson<String>(symptoms),
      'inspection': serializer.toJson<String>(inspection),
      'repairs': serializer.toJson<String>(repairs),
      'components': serializer.toJson<String>(components),
      'confidence': serializer.toJson<String>(confidence),
    };
  }

  DtcDefinition copyWith({
    String? packId,
    String? code,
    Value<String?> manufacturer = const Value.absent(),
    String? description,
    Value<String?> category = const Value.absent(),
    Value<String?> severity = const Value.absent(),
    String? causes,
    String? symptoms,
    String? inspection,
    String? repairs,
    String? components,
    String? confidence,
  }) => DtcDefinition(
    packId: packId ?? this.packId,
    code: code ?? this.code,
    manufacturer: manufacturer.present ? manufacturer.value : this.manufacturer,
    description: description ?? this.description,
    category: category.present ? category.value : this.category,
    severity: severity.present ? severity.value : this.severity,
    causes: causes ?? this.causes,
    symptoms: symptoms ?? this.symptoms,
    inspection: inspection ?? this.inspection,
    repairs: repairs ?? this.repairs,
    components: components ?? this.components,
    confidence: confidence ?? this.confidence,
  );
  DtcDefinition copyWithCompanion(DtcDefinitionsCompanion data) {
    return DtcDefinition(
      packId: data.packId.present ? data.packId.value : this.packId,
      code: data.code.present ? data.code.value : this.code,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      description: data.description.present
          ? data.description.value
          : this.description,
      category: data.category.present ? data.category.value : this.category,
      severity: data.severity.present ? data.severity.value : this.severity,
      causes: data.causes.present ? data.causes.value : this.causes,
      symptoms: data.symptoms.present ? data.symptoms.value : this.symptoms,
      inspection: data.inspection.present
          ? data.inspection.value
          : this.inspection,
      repairs: data.repairs.present ? data.repairs.value : this.repairs,
      components: data.components.present
          ? data.components.value
          : this.components,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DtcDefinition(')
          ..write('packId: $packId, ')
          ..write('code: $code, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('severity: $severity, ')
          ..write('causes: $causes, ')
          ..write('symptoms: $symptoms, ')
          ..write('inspection: $inspection, ')
          ..write('repairs: $repairs, ')
          ..write('components: $components, ')
          ..write('confidence: $confidence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    packId,
    code,
    manufacturer,
    description,
    category,
    severity,
    causes,
    symptoms,
    inspection,
    repairs,
    components,
    confidence,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DtcDefinition &&
          other.packId == this.packId &&
          other.code == this.code &&
          other.manufacturer == this.manufacturer &&
          other.description == this.description &&
          other.category == this.category &&
          other.severity == this.severity &&
          other.causes == this.causes &&
          other.symptoms == this.symptoms &&
          other.inspection == this.inspection &&
          other.repairs == this.repairs &&
          other.components == this.components &&
          other.confidence == this.confidence);
}

class DtcDefinitionsCompanion extends UpdateCompanion<DtcDefinition> {
  final Value<String> packId;
  final Value<String> code;
  final Value<String?> manufacturer;
  final Value<String> description;
  final Value<String?> category;
  final Value<String?> severity;
  final Value<String> causes;
  final Value<String> symptoms;
  final Value<String> inspection;
  final Value<String> repairs;
  final Value<String> components;
  final Value<String> confidence;
  final Value<int> rowid;
  const DtcDefinitionsCompanion({
    this.packId = const Value.absent(),
    this.code = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.severity = const Value.absent(),
    this.causes = const Value.absent(),
    this.symptoms = const Value.absent(),
    this.inspection = const Value.absent(),
    this.repairs = const Value.absent(),
    this.components = const Value.absent(),
    this.confidence = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DtcDefinitionsCompanion.insert({
    required String packId,
    required String code,
    this.manufacturer = const Value.absent(),
    required String description,
    this.category = const Value.absent(),
    this.severity = const Value.absent(),
    this.causes = const Value.absent(),
    this.symptoms = const Value.absent(),
    this.inspection = const Value.absent(),
    this.repairs = const Value.absent(),
    this.components = const Value.absent(),
    required String confidence,
    this.rowid = const Value.absent(),
  }) : packId = Value(packId),
       code = Value(code),
       description = Value(description),
       confidence = Value(confidence);
  static Insertable<DtcDefinition> custom({
    Expression<String>? packId,
    Expression<String>? code,
    Expression<String>? manufacturer,
    Expression<String>? description,
    Expression<String>? category,
    Expression<String>? severity,
    Expression<String>? causes,
    Expression<String>? symptoms,
    Expression<String>? inspection,
    Expression<String>? repairs,
    Expression<String>? components,
    Expression<String>? confidence,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (packId != null) 'pack_id': packId,
      if (code != null) 'code': code,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (severity != null) 'severity': severity,
      if (causes != null) 'causes': causes,
      if (symptoms != null) 'symptoms': symptoms,
      if (inspection != null) 'inspection': inspection,
      if (repairs != null) 'repairs': repairs,
      if (components != null) 'components': components,
      if (confidence != null) 'confidence': confidence,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DtcDefinitionsCompanion copyWith({
    Value<String>? packId,
    Value<String>? code,
    Value<String?>? manufacturer,
    Value<String>? description,
    Value<String?>? category,
    Value<String?>? severity,
    Value<String>? causes,
    Value<String>? symptoms,
    Value<String>? inspection,
    Value<String>? repairs,
    Value<String>? components,
    Value<String>? confidence,
    Value<int>? rowid,
  }) {
    return DtcDefinitionsCompanion(
      packId: packId ?? this.packId,
      code: code ?? this.code,
      manufacturer: manufacturer ?? this.manufacturer,
      description: description ?? this.description,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      causes: causes ?? this.causes,
      symptoms: symptoms ?? this.symptoms,
      inspection: inspection ?? this.inspection,
      repairs: repairs ?? this.repairs,
      components: components ?? this.components,
      confidence: confidence ?? this.confidence,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (causes.present) {
      map['causes'] = Variable<String>(causes.value);
    }
    if (symptoms.present) {
      map['symptoms'] = Variable<String>(symptoms.value);
    }
    if (inspection.present) {
      map['inspection'] = Variable<String>(inspection.value);
    }
    if (repairs.present) {
      map['repairs'] = Variable<String>(repairs.value);
    }
    if (components.present) {
      map['components'] = Variable<String>(components.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(confidence.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DtcDefinitionsCompanion(')
          ..write('packId: $packId, ')
          ..write('code: $code, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('severity: $severity, ')
          ..write('causes: $causes, ')
          ..write('symptoms: $symptoms, ')
          ..write('inspection: $inspection, ')
          ..write('repairs: $repairs, ')
          ..write('components: $components, ')
          ..write('confidence: $confidence, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$DiagDatabase extends GeneratedDatabase {
  _$DiagDatabase(QueryExecutor e) : super(e);
  $DiagDatabaseManager get managers => $DiagDatabaseManager(this);
  late final $VehiclesTable vehicles = $VehiclesTable(this);
  late final $ScansTable scans = $ScansTable(this);
  late final $ScanDtcsTable scanDtcs = $ScanDtcsTable(this);
  late final $ScanReadingsTable scanReadings = $ScanReadingsTable(this);
  late final $ScanMonitorsTable scanMonitors = $ScanMonitorsTable(this);
  late final $MaintenanceNotesTable maintenanceNotes = $MaintenanceNotesTable(
    this,
  );
  late final $AdapterProfilesTable adapterProfiles = $AdapterProfilesTable(
    this,
  );
  late final $DtcPacksTable dtcPacks = $DtcPacksTable(this);
  late final $DtcDefinitionsTable dtcDefinitions = $DtcDefinitionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vehicles,
    scans,
    scanDtcs,
    scanReadings,
    scanMonitors,
    maintenanceNotes,
    adapterProfiles,
    dtcPacks,
    dtcDefinitions,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vehicles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('scans', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'scans',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('scan_dtcs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'scans',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('scan_readings', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'scans',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('scan_monitors', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vehicles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('maintenance_notes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'dtc_packs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('dtc_definitions', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$VehiclesTableCreateCompanionBuilder =
    VehiclesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> registration,
      Value<String?> vin,
      Value<String?> manufacturer,
      Value<String?> model,
      Value<String?> engine,
      Value<int?> modelYear,
      Value<DateTime> createdAt,
    });
typedef $$VehiclesTableUpdateCompanionBuilder =
    VehiclesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> registration,
      Value<String?> vin,
      Value<String?> manufacturer,
      Value<String?> model,
      Value<String?> engine,
      Value<int?> modelYear,
      Value<DateTime> createdAt,
    });

final class $$VehiclesTableReferences
    extends BaseReferences<_$DiagDatabase, $VehiclesTable, Vehicle> {
  $$VehiclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ScansTable, List<Scan>> _scansRefsTable(
    _$DiagDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.scans,
    aliasName: 'vehicles__id__scans__vehicle_id',
  );

  $$ScansTableProcessedTableManager get scansRefs {
    final manager = $$ScansTableTableManager(
      $_db,
      $_db.scans,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_scansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MaintenanceNotesTable, List<MaintenanceNote>>
  _maintenanceNotesRefsTable(_$DiagDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.maintenanceNotes,
        aliasName: 'vehicles__id__maintenance_notes__vehicle_id',
      );

  $$MaintenanceNotesTableProcessedTableManager get maintenanceNotesRefs {
    final manager = $$MaintenanceNotesTableTableManager(
      $_db,
      $_db.maintenanceNotes,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _maintenanceNotesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VehiclesTableFilterComposer
    extends Composer<_$DiagDatabase, $VehiclesTable> {
  $$VehiclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registration => $composableBuilder(
    column: $table.registration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vin => $composableBuilder(
    column: $table.vin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get engine => $composableBuilder(
    column: $table.engine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get modelYear => $composableBuilder(
    column: $table.modelYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> scansRefs(
    Expression<bool> Function($$ScansTableFilterComposer f) f,
  ) {
    final $$ScansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scans,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScansTableFilterComposer(
            $db: $db,
            $table: $db.scans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> maintenanceNotesRefs(
    Expression<bool> Function($$MaintenanceNotesTableFilterComposer f) f,
  ) {
    final $$MaintenanceNotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenanceNotes,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceNotesTableFilterComposer(
            $db: $db,
            $table: $db.maintenanceNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehiclesTableOrderingComposer
    extends Composer<_$DiagDatabase, $VehiclesTable> {
  $$VehiclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registration => $composableBuilder(
    column: $table.registration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vin => $composableBuilder(
    column: $table.vin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get engine => $composableBuilder(
    column: $table.engine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get modelYear => $composableBuilder(
    column: $table.modelYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VehiclesTableAnnotationComposer
    extends Composer<_$DiagDatabase, $VehiclesTable> {
  $$VehiclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get registration => $composableBuilder(
    column: $table.registration,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vin =>
      $composableBuilder(column: $table.vin, builder: (column) => column);

  GeneratedColumn<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get engine =>
      $composableBuilder(column: $table.engine, builder: (column) => column);

  GeneratedColumn<int> get modelYear =>
      $composableBuilder(column: $table.modelYear, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> scansRefs<T extends Object>(
    Expression<T> Function($$ScansTableAnnotationComposer a) f,
  ) {
    final $$ScansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scans,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScansTableAnnotationComposer(
            $db: $db,
            $table: $db.scans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> maintenanceNotesRefs<T extends Object>(
    Expression<T> Function($$MaintenanceNotesTableAnnotationComposer a) f,
  ) {
    final $$MaintenanceNotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenanceNotes,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceNotesTableAnnotationComposer(
            $db: $db,
            $table: $db.maintenanceNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehiclesTableTableManager
    extends
        RootTableManager<
          _$DiagDatabase,
          $VehiclesTable,
          Vehicle,
          $$VehiclesTableFilterComposer,
          $$VehiclesTableOrderingComposer,
          $$VehiclesTableAnnotationComposer,
          $$VehiclesTableCreateCompanionBuilder,
          $$VehiclesTableUpdateCompanionBuilder,
          (Vehicle, $$VehiclesTableReferences),
          Vehicle,
          PrefetchHooks Function({bool scansRefs, bool maintenanceNotesRefs})
        > {
  $$VehiclesTableTableManager(_$DiagDatabase db, $VehiclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> registration = const Value.absent(),
                Value<String?> vin = const Value.absent(),
                Value<String?> manufacturer = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<String?> engine = const Value.absent(),
                Value<int?> modelYear = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => VehiclesCompanion(
                id: id,
                name: name,
                registration: registration,
                vin: vin,
                manufacturer: manufacturer,
                model: model,
                engine: engine,
                modelYear: modelYear,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> registration = const Value.absent(),
                Value<String?> vin = const Value.absent(),
                Value<String?> manufacturer = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<String?> engine = const Value.absent(),
                Value<int?> modelYear = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => VehiclesCompanion.insert(
                id: id,
                name: name,
                registration: registration,
                vin: vin,
                manufacturer: manufacturer,
                model: model,
                engine: engine,
                modelYear: modelYear,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VehiclesTable, Vehicle>(table),
                  $$VehiclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({scansRefs = false, maintenanceNotesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (scansRefs) db.scans,
                    if (maintenanceNotesRefs) db.maintenanceNotes,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (scansRefs)
                        await $_getPrefetchedDataByColumns<
                          Vehicle,
                          $VehiclesTable,
                          Scan,
                          $ScansTable
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._scansRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).scansRefs,
                          currentColumn: 'id',
                          referencedColumn: 'vehicle_id',
                          typedResults: items,
                        ),
                      if (maintenanceNotesRefs)
                        await $_getPrefetchedDataByColumns<
                          Vehicle,
                          $VehiclesTable,
                          MaintenanceNote,
                          $MaintenanceNotesTable
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._maintenanceNotesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).maintenanceNotesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'vehicle_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$VehiclesTableProcessedTableManager =
    ProcessedTableManager<
      _$DiagDatabase,
      $VehiclesTable,
      Vehicle,
      $$VehiclesTableFilterComposer,
      $$VehiclesTableOrderingComposer,
      $$VehiclesTableAnnotationComposer,
      $$VehiclesTableCreateCompanionBuilder,
      $$VehiclesTableUpdateCompanionBuilder,
      (Vehicle, $$VehiclesTableReferences),
      Vehicle,
      PrefetchHooks Function({bool scansRefs, bool maintenanceNotesRefs})
    >;
typedef $$ScansTableCreateCompanionBuilder =
    ScansCompanion Function({
      Value<int> id,
      Value<int?> vehicleId,
      required DateTime time,
      required String kind,
      Value<bool> simulated,
      Value<String?> vin,
      Value<String?> protocol,
      Value<String?> adapter,
      Value<double?> batteryVolts,
      Value<bool?> milOn,
      Value<String> errors,
    });
typedef $$ScansTableUpdateCompanionBuilder =
    ScansCompanion Function({
      Value<int> id,
      Value<int?> vehicleId,
      Value<DateTime> time,
      Value<String> kind,
      Value<bool> simulated,
      Value<String?> vin,
      Value<String?> protocol,
      Value<String?> adapter,
      Value<double?> batteryVolts,
      Value<bool?> milOn,
      Value<String> errors,
    });

final class $$ScansTableReferences
    extends BaseReferences<_$DiagDatabase, $ScansTable, Scan> {
  $$ScansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleIdTable(_$DiagDatabase db) =>
      db.vehicles.createAlias('scans__vehicle_id__vehicles__id');

  $$VehiclesTableProcessedTableManager? get vehicleId {
    final $_column = $_itemColumn<int>('vehicle_id');
    if ($_column == null) return null;
    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ScanDtcsTable, List<ScanDtc>> _scanDtcsRefsTable(
    _$DiagDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.scanDtcs,
    aliasName: 'scans__id__scan_dtcs__scan_id',
  );

  $$ScanDtcsTableProcessedTableManager get scanDtcsRefs {
    final manager = $$ScanDtcsTableTableManager(
      $_db,
      $_db.scanDtcs,
    ).filter((f) => f.scanId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_scanDtcsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ScanReadingsTable, List<ScanReading>>
  _scanReadingsRefsTable(_$DiagDatabase db) => MultiTypedResultKey.fromTable(
    db.scanReadings,
    aliasName: 'scans__id__scan_readings__scan_id',
  );

  $$ScanReadingsTableProcessedTableManager get scanReadingsRefs {
    final manager = $$ScanReadingsTableTableManager(
      $_db,
      $_db.scanReadings,
    ).filter((f) => f.scanId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_scanReadingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ScanMonitorsTable, List<ScanMonitor>>
  _scanMonitorsRefsTable(_$DiagDatabase db) => MultiTypedResultKey.fromTable(
    db.scanMonitors,
    aliasName: 'scans__id__scan_monitors__scan_id',
  );

  $$ScanMonitorsTableProcessedTableManager get scanMonitorsRefs {
    final manager = $$ScanMonitorsTableTableManager(
      $_db,
      $_db.scanMonitors,
    ).filter((f) => f.scanId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_scanMonitorsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ScansTableFilterComposer extends Composer<_$DiagDatabase, $ScansTable> {
  $$ScansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get simulated => $composableBuilder(
    column: $table.simulated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vin => $composableBuilder(
    column: $table.vin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get protocol => $composableBuilder(
    column: $table.protocol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adapter => $composableBuilder(
    column: $table.adapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get batteryVolts => $composableBuilder(
    column: $table.batteryVolts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get milOn => $composableBuilder(
    column: $table.milOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errors => $composableBuilder(
    column: $table.errors,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> scanDtcsRefs(
    Expression<bool> Function($$ScanDtcsTableFilterComposer f) f,
  ) {
    final $$ScanDtcsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scanDtcs,
      getReferencedColumn: (t) => t.scanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanDtcsTableFilterComposer(
            $db: $db,
            $table: $db.scanDtcs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> scanReadingsRefs(
    Expression<bool> Function($$ScanReadingsTableFilterComposer f) f,
  ) {
    final $$ScanReadingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scanReadings,
      getReferencedColumn: (t) => t.scanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanReadingsTableFilterComposer(
            $db: $db,
            $table: $db.scanReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> scanMonitorsRefs(
    Expression<bool> Function($$ScanMonitorsTableFilterComposer f) f,
  ) {
    final $$ScanMonitorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scanMonitors,
      getReferencedColumn: (t) => t.scanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanMonitorsTableFilterComposer(
            $db: $db,
            $table: $db.scanMonitors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScansTableOrderingComposer
    extends Composer<_$DiagDatabase, $ScansTable> {
  $$ScansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get simulated => $composableBuilder(
    column: $table.simulated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vin => $composableBuilder(
    column: $table.vin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get protocol => $composableBuilder(
    column: $table.protocol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adapter => $composableBuilder(
    column: $table.adapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get batteryVolts => $composableBuilder(
    column: $table.batteryVolts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get milOn => $composableBuilder(
    column: $table.milOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errors => $composableBuilder(
    column: $table.errors,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScansTableAnnotationComposer
    extends Composer<_$DiagDatabase, $ScansTable> {
  $$ScansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<bool> get simulated =>
      $composableBuilder(column: $table.simulated, builder: (column) => column);

  GeneratedColumn<String> get vin =>
      $composableBuilder(column: $table.vin, builder: (column) => column);

  GeneratedColumn<String> get protocol =>
      $composableBuilder(column: $table.protocol, builder: (column) => column);

  GeneratedColumn<String> get adapter =>
      $composableBuilder(column: $table.adapter, builder: (column) => column);

  GeneratedColumn<double> get batteryVolts => $composableBuilder(
    column: $table.batteryVolts,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get milOn =>
      $composableBuilder(column: $table.milOn, builder: (column) => column);

  GeneratedColumn<String> get errors =>
      $composableBuilder(column: $table.errors, builder: (column) => column);

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> scanDtcsRefs<T extends Object>(
    Expression<T> Function($$ScanDtcsTableAnnotationComposer a) f,
  ) {
    final $$ScanDtcsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scanDtcs,
      getReferencedColumn: (t) => t.scanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanDtcsTableAnnotationComposer(
            $db: $db,
            $table: $db.scanDtcs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> scanReadingsRefs<T extends Object>(
    Expression<T> Function($$ScanReadingsTableAnnotationComposer a) f,
  ) {
    final $$ScanReadingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scanReadings,
      getReferencedColumn: (t) => t.scanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanReadingsTableAnnotationComposer(
            $db: $db,
            $table: $db.scanReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> scanMonitorsRefs<T extends Object>(
    Expression<T> Function($$ScanMonitorsTableAnnotationComposer a) f,
  ) {
    final $$ScanMonitorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scanMonitors,
      getReferencedColumn: (t) => t.scanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanMonitorsTableAnnotationComposer(
            $db: $db,
            $table: $db.scanMonitors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScansTableTableManager
    extends
        RootTableManager<
          _$DiagDatabase,
          $ScansTable,
          Scan,
          $$ScansTableFilterComposer,
          $$ScansTableOrderingComposer,
          $$ScansTableAnnotationComposer,
          $$ScansTableCreateCompanionBuilder,
          $$ScansTableUpdateCompanionBuilder,
          (Scan, $$ScansTableReferences),
          Scan,
          PrefetchHooks Function({
            bool vehicleId,
            bool scanDtcsRefs,
            bool scanReadingsRefs,
            bool scanMonitorsRefs,
          })
        > {
  $$ScansTableTableManager(_$DiagDatabase db, $ScansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> vehicleId = const Value.absent(),
                Value<DateTime> time = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<bool> simulated = const Value.absent(),
                Value<String?> vin = const Value.absent(),
                Value<String?> protocol = const Value.absent(),
                Value<String?> adapter = const Value.absent(),
                Value<double?> batteryVolts = const Value.absent(),
                Value<bool?> milOn = const Value.absent(),
                Value<String> errors = const Value.absent(),
              }) => ScansCompanion(
                id: id,
                vehicleId: vehicleId,
                time: time,
                kind: kind,
                simulated: simulated,
                vin: vin,
                protocol: protocol,
                adapter: adapter,
                batteryVolts: batteryVolts,
                milOn: milOn,
                errors: errors,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> vehicleId = const Value.absent(),
                required DateTime time,
                required String kind,
                Value<bool> simulated = const Value.absent(),
                Value<String?> vin = const Value.absent(),
                Value<String?> protocol = const Value.absent(),
                Value<String?> adapter = const Value.absent(),
                Value<double?> batteryVolts = const Value.absent(),
                Value<bool?> milOn = const Value.absent(),
                Value<String> errors = const Value.absent(),
              }) => ScansCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                time: time,
                kind: kind,
                simulated: simulated,
                vin: vin,
                protocol: protocol,
                adapter: adapter,
                batteryVolts: batteryVolts,
                milOn: milOn,
                errors: errors,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScansTable, Scan>(table),
                  $$ScansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                vehicleId = false,
                scanDtcsRefs = false,
                scanReadingsRefs = false,
                scanMonitorsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (scanDtcsRefs) db.scanDtcs,
                    if (scanReadingsRefs) db.scanReadings,
                    if (scanMonitorsRefs) db.scanMonitors,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (vehicleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.vehicleId,
                                    referencedTable: $$ScansTableReferences
                                        ._vehicleIdTable(db),
                                    referencedColumn: $$ScansTableReferences
                                        ._vehicleIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (scanDtcsRefs)
                        await $_getPrefetchedDataByColumns<
                          Scan,
                          $ScansTable,
                          ScanDtc,
                          $ScanDtcsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ScansTableReferences
                              ._scanDtcsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScansTableReferences(
                                db,
                                table,
                                p0,
                              ).scanDtcsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'scan_id',
                          typedResults: items,
                        ),
                      if (scanReadingsRefs)
                        await $_getPrefetchedDataByColumns<
                          Scan,
                          $ScansTable,
                          ScanReading,
                          $ScanReadingsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ScansTableReferences
                              ._scanReadingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScansTableReferences(
                                db,
                                table,
                                p0,
                              ).scanReadingsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'scan_id',
                          typedResults: items,
                        ),
                      if (scanMonitorsRefs)
                        await $_getPrefetchedDataByColumns<
                          Scan,
                          $ScansTable,
                          ScanMonitor,
                          $ScanMonitorsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ScansTableReferences
                              ._scanMonitorsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScansTableReferences(
                                db,
                                table,
                                p0,
                              ).scanMonitorsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'scan_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ScansTableProcessedTableManager =
    ProcessedTableManager<
      _$DiagDatabase,
      $ScansTable,
      Scan,
      $$ScansTableFilterComposer,
      $$ScansTableOrderingComposer,
      $$ScansTableAnnotationComposer,
      $$ScansTableCreateCompanionBuilder,
      $$ScansTableUpdateCompanionBuilder,
      (Scan, $$ScansTableReferences),
      Scan,
      PrefetchHooks Function({
        bool vehicleId,
        bool scanDtcsRefs,
        bool scanReadingsRefs,
        bool scanMonitorsRefs,
      })
    >;
typedef $$ScanDtcsTableCreateCompanionBuilder =
    ScanDtcsCompanion Function({
      Value<int> id,
      required int scanId,
      required String code,
      required String status,
      Value<String?> ecu,
    });
typedef $$ScanDtcsTableUpdateCompanionBuilder =
    ScanDtcsCompanion Function({
      Value<int> id,
      Value<int> scanId,
      Value<String> code,
      Value<String> status,
      Value<String?> ecu,
    });

final class $$ScanDtcsTableReferences
    extends BaseReferences<_$DiagDatabase, $ScanDtcsTable, ScanDtc> {
  $$ScanDtcsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ScansTable _scanIdTable(_$DiagDatabase db) =>
      db.scans.createAlias('scan_dtcs__scan_id__scans__id');

  $$ScansTableProcessedTableManager get scanId {
    final $_column = $_itemColumn<int>('scan_id')!;

    final manager = $$ScansTableTableManager(
      $_db,
      $_db.scans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScanDtcsTableFilterComposer
    extends Composer<_$DiagDatabase, $ScanDtcsTable> {
  $$ScanDtcsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ecu => $composableBuilder(
    column: $table.ecu,
    builder: (column) => ColumnFilters(column),
  );

  $$ScansTableFilterComposer get scanId {
    final $$ScansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scanId,
      referencedTable: $db.scans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScansTableFilterComposer(
            $db: $db,
            $table: $db.scans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScanDtcsTableOrderingComposer
    extends Composer<_$DiagDatabase, $ScanDtcsTable> {
  $$ScanDtcsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ecu => $composableBuilder(
    column: $table.ecu,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScansTableOrderingComposer get scanId {
    final $$ScansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scanId,
      referencedTable: $db.scans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScansTableOrderingComposer(
            $db: $db,
            $table: $db.scans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScanDtcsTableAnnotationComposer
    extends Composer<_$DiagDatabase, $ScanDtcsTable> {
  $$ScanDtcsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get ecu =>
      $composableBuilder(column: $table.ecu, builder: (column) => column);

  $$ScansTableAnnotationComposer get scanId {
    final $$ScansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scanId,
      referencedTable: $db.scans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScansTableAnnotationComposer(
            $db: $db,
            $table: $db.scans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScanDtcsTableTableManager
    extends
        RootTableManager<
          _$DiagDatabase,
          $ScanDtcsTable,
          ScanDtc,
          $$ScanDtcsTableFilterComposer,
          $$ScanDtcsTableOrderingComposer,
          $$ScanDtcsTableAnnotationComposer,
          $$ScanDtcsTableCreateCompanionBuilder,
          $$ScanDtcsTableUpdateCompanionBuilder,
          (ScanDtc, $$ScanDtcsTableReferences),
          ScanDtc,
          PrefetchHooks Function({bool scanId})
        > {
  $$ScanDtcsTableTableManager(_$DiagDatabase db, $ScanDtcsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanDtcsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanDtcsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanDtcsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> scanId = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> ecu = const Value.absent(),
              }) => ScanDtcsCompanion(
                id: id,
                scanId: scanId,
                code: code,
                status: status,
                ecu: ecu,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int scanId,
                required String code,
                required String status,
                Value<String?> ecu = const Value.absent(),
              }) => ScanDtcsCompanion.insert(
                id: id,
                scanId: scanId,
                code: code,
                status: status,
                ecu: ecu,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScanDtcsTable, ScanDtc>(table),
                  $$ScanDtcsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({scanId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (scanId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.scanId,
                                referencedTable: $$ScanDtcsTableReferences
                                    ._scanIdTable(db),
                                referencedColumn: $$ScanDtcsTableReferences
                                    ._scanIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ScanDtcsTableProcessedTableManager =
    ProcessedTableManager<
      _$DiagDatabase,
      $ScanDtcsTable,
      ScanDtc,
      $$ScanDtcsTableFilterComposer,
      $$ScanDtcsTableOrderingComposer,
      $$ScanDtcsTableAnnotationComposer,
      $$ScanDtcsTableCreateCompanionBuilder,
      $$ScanDtcsTableUpdateCompanionBuilder,
      (ScanDtc, $$ScanDtcsTableReferences),
      ScanDtc,
      PrefetchHooks Function({bool scanId})
    >;
typedef $$ScanReadingsTableCreateCompanionBuilder =
    ScanReadingsCompanion Function({
      Value<int> id,
      required int scanId,
      required String source,
      required int pid,
      required String key,
      required String name,
      Value<double?> value,
      required String unit,
      Value<String?> textValue,
    });
typedef $$ScanReadingsTableUpdateCompanionBuilder =
    ScanReadingsCompanion Function({
      Value<int> id,
      Value<int> scanId,
      Value<String> source,
      Value<int> pid,
      Value<String> key,
      Value<String> name,
      Value<double?> value,
      Value<String> unit,
      Value<String?> textValue,
    });

final class $$ScanReadingsTableReferences
    extends BaseReferences<_$DiagDatabase, $ScanReadingsTable, ScanReading> {
  $$ScanReadingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ScansTable _scanIdTable(_$DiagDatabase db) =>
      db.scans.createAlias('scan_readings__scan_id__scans__id');

  $$ScansTableProcessedTableManager get scanId {
    final $_column = $_itemColumn<int>('scan_id')!;

    final manager = $$ScansTableTableManager(
      $_db,
      $_db.scans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScanReadingsTableFilterComposer
    extends Composer<_$DiagDatabase, $ScanReadingsTable> {
  $$ScanReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pid => $composableBuilder(
    column: $table.pid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnFilters(column),
  );

  $$ScansTableFilterComposer get scanId {
    final $$ScansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scanId,
      referencedTable: $db.scans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScansTableFilterComposer(
            $db: $db,
            $table: $db.scans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScanReadingsTableOrderingComposer
    extends Composer<_$DiagDatabase, $ScanReadingsTable> {
  $$ScanReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pid => $composableBuilder(
    column: $table.pid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScansTableOrderingComposer get scanId {
    final $$ScansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scanId,
      referencedTable: $db.scans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScansTableOrderingComposer(
            $db: $db,
            $table: $db.scans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScanReadingsTableAnnotationComposer
    extends Composer<_$DiagDatabase, $ScanReadingsTable> {
  $$ScanReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get pid =>
      $composableBuilder(column: $table.pid, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get textValue =>
      $composableBuilder(column: $table.textValue, builder: (column) => column);

  $$ScansTableAnnotationComposer get scanId {
    final $$ScansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scanId,
      referencedTable: $db.scans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScansTableAnnotationComposer(
            $db: $db,
            $table: $db.scans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScanReadingsTableTableManager
    extends
        RootTableManager<
          _$DiagDatabase,
          $ScanReadingsTable,
          ScanReading,
          $$ScanReadingsTableFilterComposer,
          $$ScanReadingsTableOrderingComposer,
          $$ScanReadingsTableAnnotationComposer,
          $$ScanReadingsTableCreateCompanionBuilder,
          $$ScanReadingsTableUpdateCompanionBuilder,
          (ScanReading, $$ScanReadingsTableReferences),
          ScanReading,
          PrefetchHooks Function({bool scanId})
        > {
  $$ScanReadingsTableTableManager(_$DiagDatabase db, $ScanReadingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanReadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> scanId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> pid = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double?> value = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String?> textValue = const Value.absent(),
              }) => ScanReadingsCompanion(
                id: id,
                scanId: scanId,
                source: source,
                pid: pid,
                key: key,
                name: name,
                value: value,
                unit: unit,
                textValue: textValue,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int scanId,
                required String source,
                required int pid,
                required String key,
                required String name,
                Value<double?> value = const Value.absent(),
                required String unit,
                Value<String?> textValue = const Value.absent(),
              }) => ScanReadingsCompanion.insert(
                id: id,
                scanId: scanId,
                source: source,
                pid: pid,
                key: key,
                name: name,
                value: value,
                unit: unit,
                textValue: textValue,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScanReadingsTable, ScanReading>(table),
                  $$ScanReadingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({scanId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (scanId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.scanId,
                                referencedTable: $$ScanReadingsTableReferences
                                    ._scanIdTable(db),
                                referencedColumn: $$ScanReadingsTableReferences
                                    ._scanIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ScanReadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$DiagDatabase,
      $ScanReadingsTable,
      ScanReading,
      $$ScanReadingsTableFilterComposer,
      $$ScanReadingsTableOrderingComposer,
      $$ScanReadingsTableAnnotationComposer,
      $$ScanReadingsTableCreateCompanionBuilder,
      $$ScanReadingsTableUpdateCompanionBuilder,
      (ScanReading, $$ScanReadingsTableReferences),
      ScanReading,
      PrefetchHooks Function({bool scanId})
    >;
typedef $$ScanMonitorsTableCreateCompanionBuilder =
    ScanMonitorsCompanion Function({
      Value<int> id,
      required int scanId,
      required String key,
      required String name,
      required String state,
    });
typedef $$ScanMonitorsTableUpdateCompanionBuilder =
    ScanMonitorsCompanion Function({
      Value<int> id,
      Value<int> scanId,
      Value<String> key,
      Value<String> name,
      Value<String> state,
    });

final class $$ScanMonitorsTableReferences
    extends BaseReferences<_$DiagDatabase, $ScanMonitorsTable, ScanMonitor> {
  $$ScanMonitorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ScansTable _scanIdTable(_$DiagDatabase db) =>
      db.scans.createAlias('scan_monitors__scan_id__scans__id');

  $$ScansTableProcessedTableManager get scanId {
    final $_column = $_itemColumn<int>('scan_id')!;

    final manager = $$ScansTableTableManager(
      $_db,
      $_db.scans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScanMonitorsTableFilterComposer
    extends Composer<_$DiagDatabase, $ScanMonitorsTable> {
  $$ScanMonitorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  $$ScansTableFilterComposer get scanId {
    final $$ScansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scanId,
      referencedTable: $db.scans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScansTableFilterComposer(
            $db: $db,
            $table: $db.scans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScanMonitorsTableOrderingComposer
    extends Composer<_$DiagDatabase, $ScanMonitorsTable> {
  $$ScanMonitorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScansTableOrderingComposer get scanId {
    final $$ScansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scanId,
      referencedTable: $db.scans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScansTableOrderingComposer(
            $db: $db,
            $table: $db.scans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScanMonitorsTableAnnotationComposer
    extends Composer<_$DiagDatabase, $ScanMonitorsTable> {
  $$ScanMonitorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  $$ScansTableAnnotationComposer get scanId {
    final $$ScansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scanId,
      referencedTable: $db.scans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScansTableAnnotationComposer(
            $db: $db,
            $table: $db.scans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScanMonitorsTableTableManager
    extends
        RootTableManager<
          _$DiagDatabase,
          $ScanMonitorsTable,
          ScanMonitor,
          $$ScanMonitorsTableFilterComposer,
          $$ScanMonitorsTableOrderingComposer,
          $$ScanMonitorsTableAnnotationComposer,
          $$ScanMonitorsTableCreateCompanionBuilder,
          $$ScanMonitorsTableUpdateCompanionBuilder,
          (ScanMonitor, $$ScanMonitorsTableReferences),
          ScanMonitor,
          PrefetchHooks Function({bool scanId})
        > {
  $$ScanMonitorsTableTableManager(_$DiagDatabase db, $ScanMonitorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanMonitorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanMonitorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanMonitorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> scanId = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> state = const Value.absent(),
              }) => ScanMonitorsCompanion(
                id: id,
                scanId: scanId,
                key: key,
                name: name,
                state: state,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int scanId,
                required String key,
                required String name,
                required String state,
              }) => ScanMonitorsCompanion.insert(
                id: id,
                scanId: scanId,
                key: key,
                name: name,
                state: state,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScanMonitorsTable, ScanMonitor>(table),
                  $$ScanMonitorsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({scanId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (scanId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.scanId,
                                referencedTable: $$ScanMonitorsTableReferences
                                    ._scanIdTable(db),
                                referencedColumn: $$ScanMonitorsTableReferences
                                    ._scanIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ScanMonitorsTableProcessedTableManager =
    ProcessedTableManager<
      _$DiagDatabase,
      $ScanMonitorsTable,
      ScanMonitor,
      $$ScanMonitorsTableFilterComposer,
      $$ScanMonitorsTableOrderingComposer,
      $$ScanMonitorsTableAnnotationComposer,
      $$ScanMonitorsTableCreateCompanionBuilder,
      $$ScanMonitorsTableUpdateCompanionBuilder,
      (ScanMonitor, $$ScanMonitorsTableReferences),
      ScanMonitor,
      PrefetchHooks Function({bool scanId})
    >;
typedef $$MaintenanceNotesTableCreateCompanionBuilder =
    MaintenanceNotesCompanion Function({
      Value<int> id,
      required int vehicleId,
      Value<DateTime> time,
      required String body,
    });
typedef $$MaintenanceNotesTableUpdateCompanionBuilder =
    MaintenanceNotesCompanion Function({
      Value<int> id,
      Value<int> vehicleId,
      Value<DateTime> time,
      Value<String> body,
    });

final class $$MaintenanceNotesTableReferences
    extends
        BaseReferences<
          _$DiagDatabase,
          $MaintenanceNotesTable,
          MaintenanceNote
        > {
  $$MaintenanceNotesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VehiclesTable _vehicleIdTable(_$DiagDatabase db) =>
      db.vehicles.createAlias('maintenance_notes__vehicle_id__vehicles__id');

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<int>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MaintenanceNotesTableFilterComposer
    extends Composer<_$DiagDatabase, $MaintenanceNotesTable> {
  $$MaintenanceNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceNotesTableOrderingComposer
    extends Composer<_$DiagDatabase, $MaintenanceNotesTable> {
  $$MaintenanceNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceNotesTableAnnotationComposer
    extends Composer<_$DiagDatabase, $MaintenanceNotesTable> {
  $$MaintenanceNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceNotesTableTableManager
    extends
        RootTableManager<
          _$DiagDatabase,
          $MaintenanceNotesTable,
          MaintenanceNote,
          $$MaintenanceNotesTableFilterComposer,
          $$MaintenanceNotesTableOrderingComposer,
          $$MaintenanceNotesTableAnnotationComposer,
          $$MaintenanceNotesTableCreateCompanionBuilder,
          $$MaintenanceNotesTableUpdateCompanionBuilder,
          (MaintenanceNote, $$MaintenanceNotesTableReferences),
          MaintenanceNote,
          PrefetchHooks Function({bool vehicleId})
        > {
  $$MaintenanceNotesTableTableManager(
    _$DiagDatabase db,
    $MaintenanceNotesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaintenanceNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaintenanceNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MaintenanceNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> vehicleId = const Value.absent(),
                Value<DateTime> time = const Value.absent(),
                Value<String> body = const Value.absent(),
              }) => MaintenanceNotesCompanion(
                id: id,
                vehicleId: vehicleId,
                time: time,
                body: body,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int vehicleId,
                Value<DateTime> time = const Value.absent(),
                required String body,
              }) => MaintenanceNotesCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                time: time,
                body: body,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MaintenanceNotesTable, MaintenanceNote>(table),
                  $$MaintenanceNotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vehicleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.vehicleId,
                                referencedTable:
                                    $$MaintenanceNotesTableReferences
                                        ._vehicleIdTable(db),
                                referencedColumn:
                                    $$MaintenanceNotesTableReferences
                                        ._vehicleIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MaintenanceNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$DiagDatabase,
      $MaintenanceNotesTable,
      MaintenanceNote,
      $$MaintenanceNotesTableFilterComposer,
      $$MaintenanceNotesTableOrderingComposer,
      $$MaintenanceNotesTableAnnotationComposer,
      $$MaintenanceNotesTableCreateCompanionBuilder,
      $$MaintenanceNotesTableUpdateCompanionBuilder,
      (MaintenanceNote, $$MaintenanceNotesTableReferences),
      MaintenanceNote,
      PrefetchHooks Function({bool vehicleId})
    >;
typedef $$AdapterProfilesTableCreateCompanionBuilder =
    AdapterProfilesCompanion Function({
      required String address,
      required String kind,
      required String identity,
      required String manufacturer,
      required String capabilities,
      required DateTime lastSeen,
      Value<int> rowid,
    });
typedef $$AdapterProfilesTableUpdateCompanionBuilder =
    AdapterProfilesCompanion Function({
      Value<String> address,
      Value<String> kind,
      Value<String> identity,
      Value<String> manufacturer,
      Value<String> capabilities,
      Value<DateTime> lastSeen,
      Value<int> rowid,
    });

class $$AdapterProfilesTableFilterComposer
    extends Composer<_$DiagDatabase, $AdapterProfilesTable> {
  $$AdapterProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get identity => $composableBuilder(
    column: $table.identity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get capabilities => $composableBuilder(
    column: $table.capabilities,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AdapterProfilesTableOrderingComposer
    extends Composer<_$DiagDatabase, $AdapterProfilesTable> {
  $$AdapterProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get identity => $composableBuilder(
    column: $table.identity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get capabilities => $composableBuilder(
    column: $table.capabilities,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AdapterProfilesTableAnnotationComposer
    extends Composer<_$DiagDatabase, $AdapterProfilesTable> {
  $$AdapterProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get identity =>
      $composableBuilder(column: $table.identity, builder: (column) => column);

  GeneratedColumn<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get capabilities => $composableBuilder(
    column: $table.capabilities,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSeen =>
      $composableBuilder(column: $table.lastSeen, builder: (column) => column);
}

class $$AdapterProfilesTableTableManager
    extends
        RootTableManager<
          _$DiagDatabase,
          $AdapterProfilesTable,
          AdapterProfile,
          $$AdapterProfilesTableFilterComposer,
          $$AdapterProfilesTableOrderingComposer,
          $$AdapterProfilesTableAnnotationComposer,
          $$AdapterProfilesTableCreateCompanionBuilder,
          $$AdapterProfilesTableUpdateCompanionBuilder,
          (
            AdapterProfile,
            BaseReferences<
              _$DiagDatabase,
              $AdapterProfilesTable,
              AdapterProfile
            >,
          ),
          AdapterProfile,
          PrefetchHooks Function()
        > {
  $$AdapterProfilesTableTableManager(
    _$DiagDatabase db,
    $AdapterProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdapterProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdapterProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdapterProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> address = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> identity = const Value.absent(),
                Value<String> manufacturer = const Value.absent(),
                Value<String> capabilities = const Value.absent(),
                Value<DateTime> lastSeen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdapterProfilesCompanion(
                address: address,
                kind: kind,
                identity: identity,
                manufacturer: manufacturer,
                capabilities: capabilities,
                lastSeen: lastSeen,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String address,
                required String kind,
                required String identity,
                required String manufacturer,
                required String capabilities,
                required DateTime lastSeen,
                Value<int> rowid = const Value.absent(),
              }) => AdapterProfilesCompanion.insert(
                address: address,
                kind: kind,
                identity: identity,
                manufacturer: manufacturer,
                capabilities: capabilities,
                lastSeen: lastSeen,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AdapterProfilesTable, AdapterProfile>(table),
                  BaseReferences<
                    _$DiagDatabase,
                    $AdapterProfilesTable,
                    AdapterProfile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AdapterProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$DiagDatabase,
      $AdapterProfilesTable,
      AdapterProfile,
      $$AdapterProfilesTableFilterComposer,
      $$AdapterProfilesTableOrderingComposer,
      $$AdapterProfilesTableAnnotationComposer,
      $$AdapterProfilesTableCreateCompanionBuilder,
      $$AdapterProfilesTableUpdateCompanionBuilder,
      (
        AdapterProfile,
        BaseReferences<_$DiagDatabase, $AdapterProfilesTable, AdapterProfile>,
      ),
      AdapterProfile,
      PrefetchHooks Function()
    >;
typedef $$DtcPacksTableCreateCompanionBuilder =
    DtcPacksCompanion Function({
      required String id,
      required String title,
      required String version,
      required String source,
      required String scope,
      Value<DateTime> installedAt,
      Value<int> rowid,
    });
typedef $$DtcPacksTableUpdateCompanionBuilder =
    DtcPacksCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> version,
      Value<String> source,
      Value<String> scope,
      Value<DateTime> installedAt,
      Value<int> rowid,
    });

final class $$DtcPacksTableReferences
    extends BaseReferences<_$DiagDatabase, $DtcPacksTable, DtcPack> {
  $$DtcPacksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DtcDefinitionsTable, List<DtcDefinition>>
  _dtcDefinitionsRefsTable(_$DiagDatabase db) => MultiTypedResultKey.fromTable(
    db.dtcDefinitions,
    aliasName: 'dtc_packs__id__dtc_definitions__pack_id',
  );

  $$DtcDefinitionsTableProcessedTableManager get dtcDefinitionsRefs {
    final manager = $$DtcDefinitionsTableTableManager(
      $_db,
      $_db.dtcDefinitions,
    ).filter((f) => f.packId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_dtcDefinitionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DtcPacksTableFilterComposer
    extends Composer<_$DiagDatabase, $DtcPacksTable> {
  $$DtcPacksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> dtcDefinitionsRefs(
    Expression<bool> Function($$DtcDefinitionsTableFilterComposer f) f,
  ) {
    final $$DtcDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dtcDefinitions,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DtcDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.dtcDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DtcPacksTableOrderingComposer
    extends Composer<_$DiagDatabase, $DtcPacksTable> {
  $$DtcPacksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DtcPacksTableAnnotationComposer
    extends Composer<_$DiagDatabase, $DtcPacksTable> {
  $$DtcPacksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => column,
  );

  Expression<T> dtcDefinitionsRefs<T extends Object>(
    Expression<T> Function($$DtcDefinitionsTableAnnotationComposer a) f,
  ) {
    final $$DtcDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dtcDefinitions,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DtcDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.dtcDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DtcPacksTableTableManager
    extends
        RootTableManager<
          _$DiagDatabase,
          $DtcPacksTable,
          DtcPack,
          $$DtcPacksTableFilterComposer,
          $$DtcPacksTableOrderingComposer,
          $$DtcPacksTableAnnotationComposer,
          $$DtcPacksTableCreateCompanionBuilder,
          $$DtcPacksTableUpdateCompanionBuilder,
          (DtcPack, $$DtcPacksTableReferences),
          DtcPack,
          PrefetchHooks Function({bool dtcDefinitionsRefs})
        > {
  $$DtcPacksTableTableManager(_$DiagDatabase db, $DtcPacksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DtcPacksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DtcPacksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DtcPacksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<DateTime> installedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DtcPacksCompanion(
                id: id,
                title: title,
                version: version,
                source: source,
                scope: scope,
                installedAt: installedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String version,
                required String source,
                required String scope,
                Value<DateTime> installedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DtcPacksCompanion.insert(
                id: id,
                title: title,
                version: version,
                source: source,
                scope: scope,
                installedAt: installedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DtcPacksTable, DtcPack>(table),
                  $$DtcPacksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dtcDefinitionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (dtcDefinitionsRefs) db.dtcDefinitions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dtcDefinitionsRefs)
                    await $_getPrefetchedDataByColumns<
                      DtcPack,
                      $DtcPacksTable,
                      DtcDefinition,
                      $DtcDefinitionsTable
                    >(
                      currentTable: table,
                      referencedTable: $$DtcPacksTableReferences
                          ._dtcDefinitionsRefsTable(db),
                      managerFromTypedResult: (p0) => $$DtcPacksTableReferences(
                        db,
                        table,
                        p0,
                      ).dtcDefinitionsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'pack_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DtcPacksTableProcessedTableManager =
    ProcessedTableManager<
      _$DiagDatabase,
      $DtcPacksTable,
      DtcPack,
      $$DtcPacksTableFilterComposer,
      $$DtcPacksTableOrderingComposer,
      $$DtcPacksTableAnnotationComposer,
      $$DtcPacksTableCreateCompanionBuilder,
      $$DtcPacksTableUpdateCompanionBuilder,
      (DtcPack, $$DtcPacksTableReferences),
      DtcPack,
      PrefetchHooks Function({bool dtcDefinitionsRefs})
    >;
typedef $$DtcDefinitionsTableCreateCompanionBuilder =
    DtcDefinitionsCompanion Function({
      required String packId,
      required String code,
      Value<String?> manufacturer,
      required String description,
      Value<String?> category,
      Value<String?> severity,
      Value<String> causes,
      Value<String> symptoms,
      Value<String> inspection,
      Value<String> repairs,
      Value<String> components,
      required String confidence,
      Value<int> rowid,
    });
typedef $$DtcDefinitionsTableUpdateCompanionBuilder =
    DtcDefinitionsCompanion Function({
      Value<String> packId,
      Value<String> code,
      Value<String?> manufacturer,
      Value<String> description,
      Value<String?> category,
      Value<String?> severity,
      Value<String> causes,
      Value<String> symptoms,
      Value<String> inspection,
      Value<String> repairs,
      Value<String> components,
      Value<String> confidence,
      Value<int> rowid,
    });

final class $$DtcDefinitionsTableReferences
    extends
        BaseReferences<_$DiagDatabase, $DtcDefinitionsTable, DtcDefinition> {
  $$DtcDefinitionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DtcPacksTable _packIdTable(_$DiagDatabase db) =>
      db.dtcPacks.createAlias('dtc_definitions__pack_id__dtc_packs__id');

  $$DtcPacksTableProcessedTableManager get packId {
    final $_column = $_itemColumn<String>('pack_id')!;

    final manager = $$DtcPacksTableTableManager(
      $_db,
      $_db.dtcPacks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_packIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DtcDefinitionsTableFilterComposer
    extends Composer<_$DiagDatabase, $DtcDefinitionsTable> {
  $$DtcDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get causes => $composableBuilder(
    column: $table.causes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symptoms => $composableBuilder(
    column: $table.symptoms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inspection => $composableBuilder(
    column: $table.inspection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repairs => $composableBuilder(
    column: $table.repairs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get components => $composableBuilder(
    column: $table.components,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  $$DtcPacksTableFilterComposer get packId {
    final $$DtcPacksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.dtcPacks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DtcPacksTableFilterComposer(
            $db: $db,
            $table: $db.dtcPacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DtcDefinitionsTableOrderingComposer
    extends Composer<_$DiagDatabase, $DtcDefinitionsTable> {
  $$DtcDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get causes => $composableBuilder(
    column: $table.causes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symptoms => $composableBuilder(
    column: $table.symptoms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inspection => $composableBuilder(
    column: $table.inspection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repairs => $composableBuilder(
    column: $table.repairs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get components => $composableBuilder(
    column: $table.components,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  $$DtcPacksTableOrderingComposer get packId {
    final $$DtcPacksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.dtcPacks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DtcPacksTableOrderingComposer(
            $db: $db,
            $table: $db.dtcPacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DtcDefinitionsTableAnnotationComposer
    extends Composer<_$DiagDatabase, $DtcDefinitionsTable> {
  $$DtcDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get causes =>
      $composableBuilder(column: $table.causes, builder: (column) => column);

  GeneratedColumn<String> get symptoms =>
      $composableBuilder(column: $table.symptoms, builder: (column) => column);

  GeneratedColumn<String> get inspection => $composableBuilder(
    column: $table.inspection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repairs =>
      $composableBuilder(column: $table.repairs, builder: (column) => column);

  GeneratedColumn<String> get components => $composableBuilder(
    column: $table.components,
    builder: (column) => column,
  );

  GeneratedColumn<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  $$DtcPacksTableAnnotationComposer get packId {
    final $$DtcPacksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.dtcPacks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DtcPacksTableAnnotationComposer(
            $db: $db,
            $table: $db.dtcPacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DtcDefinitionsTableTableManager
    extends
        RootTableManager<
          _$DiagDatabase,
          $DtcDefinitionsTable,
          DtcDefinition,
          $$DtcDefinitionsTableFilterComposer,
          $$DtcDefinitionsTableOrderingComposer,
          $$DtcDefinitionsTableAnnotationComposer,
          $$DtcDefinitionsTableCreateCompanionBuilder,
          $$DtcDefinitionsTableUpdateCompanionBuilder,
          (DtcDefinition, $$DtcDefinitionsTableReferences),
          DtcDefinition,
          PrefetchHooks Function({bool packId})
        > {
  $$DtcDefinitionsTableTableManager(
    _$DiagDatabase db,
    $DtcDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DtcDefinitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DtcDefinitionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DtcDefinitionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> packId = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String?> manufacturer = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> severity = const Value.absent(),
                Value<String> causes = const Value.absent(),
                Value<String> symptoms = const Value.absent(),
                Value<String> inspection = const Value.absent(),
                Value<String> repairs = const Value.absent(),
                Value<String> components = const Value.absent(),
                Value<String> confidence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DtcDefinitionsCompanion(
                packId: packId,
                code: code,
                manufacturer: manufacturer,
                description: description,
                category: category,
                severity: severity,
                causes: causes,
                symptoms: symptoms,
                inspection: inspection,
                repairs: repairs,
                components: components,
                confidence: confidence,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String packId,
                required String code,
                Value<String?> manufacturer = const Value.absent(),
                required String description,
                Value<String?> category = const Value.absent(),
                Value<String?> severity = const Value.absent(),
                Value<String> causes = const Value.absent(),
                Value<String> symptoms = const Value.absent(),
                Value<String> inspection = const Value.absent(),
                Value<String> repairs = const Value.absent(),
                Value<String> components = const Value.absent(),
                required String confidence,
                Value<int> rowid = const Value.absent(),
              }) => DtcDefinitionsCompanion.insert(
                packId: packId,
                code: code,
                manufacturer: manufacturer,
                description: description,
                category: category,
                severity: severity,
                causes: causes,
                symptoms: symptoms,
                inspection: inspection,
                repairs: repairs,
                components: components,
                confidence: confidence,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DtcDefinitionsTable, DtcDefinition>(table),
                  $$DtcDefinitionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({packId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (packId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.packId,
                                referencedTable: $$DtcDefinitionsTableReferences
                                    ._packIdTable(db),
                                referencedColumn:
                                    $$DtcDefinitionsTableReferences
                                        ._packIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DtcDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$DiagDatabase,
      $DtcDefinitionsTable,
      DtcDefinition,
      $$DtcDefinitionsTableFilterComposer,
      $$DtcDefinitionsTableOrderingComposer,
      $$DtcDefinitionsTableAnnotationComposer,
      $$DtcDefinitionsTableCreateCompanionBuilder,
      $$DtcDefinitionsTableUpdateCompanionBuilder,
      (DtcDefinition, $$DtcDefinitionsTableReferences),
      DtcDefinition,
      PrefetchHooks Function({bool packId})
    >;

class $DiagDatabaseManager {
  final _$DiagDatabase _db;
  $DiagDatabaseManager(this._db);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db, _db.vehicles);
  $$ScansTableTableManager get scans =>
      $$ScansTableTableManager(_db, _db.scans);
  $$ScanDtcsTableTableManager get scanDtcs =>
      $$ScanDtcsTableTableManager(_db, _db.scanDtcs);
  $$ScanReadingsTableTableManager get scanReadings =>
      $$ScanReadingsTableTableManager(_db, _db.scanReadings);
  $$ScanMonitorsTableTableManager get scanMonitors =>
      $$ScanMonitorsTableTableManager(_db, _db.scanMonitors);
  $$MaintenanceNotesTableTableManager get maintenanceNotes =>
      $$MaintenanceNotesTableTableManager(_db, _db.maintenanceNotes);
  $$AdapterProfilesTableTableManager get adapterProfiles =>
      $$AdapterProfilesTableTableManager(_db, _db.adapterProfiles);
  $$DtcPacksTableTableManager get dtcPacks =>
      $$DtcPacksTableTableManager(_db, _db.dtcPacks);
  $$DtcDefinitionsTableTableManager get dtcDefinitions =>
      $$DtcDefinitionsTableTableManager(_db, _db.dtcDefinitions);
}
