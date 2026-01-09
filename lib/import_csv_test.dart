import 'dart:developer';
import 'package:etymology/services/remote_services.dart';

/// Run this function to import CSV and verify
/// Call from main.dart or run as a one-time script
Future<void> runCsvImport() async {
  log('=== Starting CSV Import ===');
  
  // Step 1: Verify current status
  log('\n--- Checking current database status ---');
  final status = await verifyCsvImportStatus();
  log('CSV Total Terms: ${status['csvTotal']}');
  log('Database Total Terms: ${status['dbTotal']}');
  log('CSV Terms Found in DB: ${status['foundInDb']}');
  log('CSV Terms NOT in DB: ${status['notFoundInDb']}');
  if ((status['sampleNotFound'] as List).isNotEmpty) {
    log('Sample missing terms: ${status['sampleNotFound']}');
  }
  
  // Step 2: Run import
  log('\n--- Running Import ---');
  final result = await importMedicalTermsFromCsv();
  log('Import Result:');
  log('  - Inserted: ${result['inserted']}');
  log('  - Updated: ${result['updated']}');
  log('  - Errors: ${result['errors']}');
  
  // Step 3: Verify after import
  log('\n--- Verifying after import ---');
  final statusAfter = await verifyCsvImportStatus();
  log('CSV Total Terms: ${statusAfter['csvTotal']}');
  log('Database Total Terms: ${statusAfter['dbTotal']}');
  log('CSV Terms Found in DB: ${statusAfter['foundInDb']}');
  log('CSV Terms NOT in DB: ${statusAfter['notFoundInDb']}');
  
  log('\n=== Import Complete ===');
}

