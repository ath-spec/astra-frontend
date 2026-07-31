import 'dart:io';

void main() {
  final dir = Directory('d:/astra-frontend/lib/features/mf/screens/fund_profile/widgets');
  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      final content = file.readAsStringSync();
      final newContent = content.replaceAll('FontWeight.w700', 'FontWeight.w600');
      if (content != newContent) {
        file.writeAsStringSync(newContent);
        print('Updated ${file.path}');
      }
    }
  }

  // Update MfFundAssetAllocation call in mf_fund_profile_screen.dart
  final profileFile = File('d:/astra-frontend/lib/features/mf/screens/fund_profile/mf_fund_profile_screen.dart');
  var profileContent = profileFile.readAsStringSync();
  profileContent = profileContent.replaceAll(
    'MfFundAssetAllocation(data: processedData.assetAllocation),',
    'MfFundAssetAllocation(data: processedData.assetAllocation ?? MfMockFundData.mockAssetAllocation),',
  );
  profileFile.writeAsStringSync(profileContent);
  print('Updated mf_fund_profile_screen.dart');

  // Update mf_mock_fund_data.dart to expose mockAssetAllocation
  final mockFile = File('d:/astra-frontend/lib/features/mf/screens/mf_explore/data/mf_mock_fund_data.dart');
  var mockContent = mockFile.readAsStringSync();
  if (!mockContent.contains('static AssetAllocationData get mockAssetAllocation')) {
    mockContent = mockContent.replaceFirst(
      'static final AssetAllocationData _mockAssetAllocation = AssetAllocationData(',
      'static AssetAllocationData get mockAssetAllocation => _mockAssetAllocation;\n  static final AssetAllocationData _mockAssetAllocation = AssetAllocationData('
    );
    mockFile.writeAsStringSync(mockContent);
    print('Updated mf_mock_fund_data.dart');
  }
}
