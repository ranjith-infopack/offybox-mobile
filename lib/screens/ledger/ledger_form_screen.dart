import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/outlet.dart';
import '../../services/outlet_service.dart';
import 'package:geolocator/geolocator.dart';

class LedgerFormScreen extends StatefulWidget {
  const LedgerFormScreen({super.key});

  @override
  State<LedgerFormScreen> createState() => _LedgerFormScreenState();
}

class _LedgerFormScreenState extends State<LedgerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController(text: 'Demo Name');
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _mobileController = TextEditingController();
  final _creditLimitController = TextEditingController(text: '0');
  final _gstnController = TextEditingController();
  final _panController = TextEditingController();
  final _dateController = TextEditingController(text: DateFormat('MM/dd/yyyy').format(DateTime.now()));

  // Dropdown values
  String? _selectedType;
  String? _selectedGroupId;
  String _selectedStatus = 'ACTIVE';
  String? _selectedSalesPersonId;
  
  // Location
  double? _latitude;
  double? _longitude;
  DateTime? _locationFetchedAt;
  bool _isFetchingLocation = false;

  // Lists for dropdowns
  List<LedgerGroup> _ledgerGroups = [];
  List<SalesPerson> _salesPersons = [];
  
  bool _isLoading = false;
  bool _isFetchingInitialData = true;

  final List<String> _ledgerTypes = ['DEALER', 'CUSTOMER', 'SUPPLIER', 'BOTH'];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _mobileController.dispose();
    _creditLimitController.dispose();
    _gstnController.dispose();
    _panController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    print('LedgerFormScreen: Fetching initial data...');
    try {
      final results = await Future.wait([
        OutletService.getLedgerGroups(),
        OutletService.getSalesPersons(),
      ]);
      print('LedgerFormScreen: Fetch results received');

      if (mounted) {
        setState(() {
          if (results[0]['success']) {
            _ledgerGroups = results[0]['data'] as List<LedgerGroup>;
            print('LedgerFormScreen: _ledgerGroups loaded: ${_ledgerGroups.length} items');
            if (_ledgerGroups.isNotEmpty && _selectedGroupId == null) {
              _selectedGroupId = _ledgerGroups.first.id;
            }
          } else {
            print('LedgerFormScreen: Ledger Groups fetch failed: ${results[0]['message']}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load ledger groups: ${results[0]['message']}')),
            );
          }
          if (results[1]['success']) {
            _salesPersons = results[1]['data'] as List<SalesPerson>;
            print('LedgerFormScreen: _salesPersons loaded: ${_salesPersons.length} items');
            if (_salesPersons.isNotEmpty && _selectedSalesPersonId == null) {
              _selectedSalesPersonId = _salesPersons.first.id;
            }
          } else {
            print('LedgerFormScreen: Sales Persons fetch failed: ${results[1]['message']}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load sales persons: ${results[1]['message']}')),
            );
          }
          _isFetchingInitialData = false;
        });
      }
    } catch (e) {
      print('LedgerFormScreen: Error fetching initial data: $e');
      if (mounted) {
        setState(() {
          _isFetchingInitialData = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading initial data: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isFetchingLocation = true;
    });

    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled.')),
          );
        }
        setState(() => _isFetchingLocation = false);
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')),
            );
          }
          setState(() => _isFetchingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are permanently denied.')),
          );
        }
        setState(() => _isFetchingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationFetchedAt = DateTime.now();
        _isFetchingLocation = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching location: $e')),
        );
      }
      setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final data = {
      'company_name': _nameController.text.trim(),
      'outlet_type': _selectedType,
      'outlet_category_id': _selectedGroupId,
      'incorporation_date': _dateController.text, // Backend might expect ISO, but following user request for display
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'mobile': _mobileController.text.trim(),
      'credit_limit': _creditLimitController.text,
      'gstn': _gstnController.text.trim(),
      'status': _selectedStatus,
      'pan': _panController.text.trim(),
      'sales_person_id': _selectedSalesPersonId,
      'latitude': _latitude,
      'longitude': _longitude,
      'location_fetched_at': _locationFetchedAt?.toIso8601String(),
    };

    final result = await OutletService.createOutlet(data);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ledger added successfully')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to add ledger')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetchingInitialData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        title: const Text('Add Ledger', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Company Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 16),
              
              _buildLabel('Ledger Name *'),
              _buildTextField(_nameController, 'Enter Ledger Name', (v) => v!.isEmpty ? 'Please enter ledger name' : null),
              
              _buildLabel('Ledger Type *'),
              _buildDropdown(
                value: _selectedType,
                hint: 'Select Ledger Type',
                items: _ledgerTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _selectedType = v),
                validator: (v) => v == null ? 'Please select ledger type' : null,
              ),

              _buildLabel('Ledger Group *'),
              _buildDropdown(
                value: _selectedGroupId,
                hint: _ledgerGroups.isEmpty ? 'No Ledger Groups Available' : 'Select Ledger Group',
                items: _ledgerGroups.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name.isEmpty ? 'Unnamed Group' : c.name))).toList(),
                onChanged: (v) => setState(() => _selectedGroupId = v),
                validator: (v) => v == null ? 'Please select ledger group' : null,
              ),

              _buildLabel('Incorporation Date'),
              _buildDateField(),

              _buildLabel('Company Email'),
              _buildTextField(_emailController, 'Enter Company Email', null, keyboardType: TextInputType.emailAddress),

              _buildLabel('Phone'),
              _buildTextField(_phoneController, 'Enter Phone Number', null, keyboardType: TextInputType.phone),

              _buildLabel('Mobile'),
              _buildTextField(_mobileController, 'Enter Mobile Number', null, keyboardType: TextInputType.phone),

              _buildLabel('Credit Limit'),
              _buildTextField(_creditLimitController, '0', null, keyboardType: TextInputType.number),

              _buildLabel('GSTN'),
              _buildTextField(_gstnController, 'e.g., 33AABCU9603R1ZM', null),

              _buildLabel('Status'),
              _buildDropdown(
                value: _selectedStatus,
                hint: 'Select Status',
                items: const [
                  DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
                  DropdownMenuItem(value: 'INACTIVE', child: Text('Inactive')),
                ],
                onChanged: (v) => setState(() => _selectedStatus = v!),
              ),

              _buildLabel('PAN'),
              _buildTextField(_panController, 'e.g., AABCU9603R', null),

              _buildLabel('Sales Person *'),
              _buildDropdown(
                value: _selectedSalesPersonId,
                hint: _salesPersons.isEmpty ? 'No Sales Persons Available' : 'Select Sales Person',
                items: _salesPersons.map((s) => DropdownMenuItem(value: s.id, child: Text(s.fullName.trim().isEmpty ? 'Unnamed Person' : s.fullName))).toList(),
                onChanged: (v) => setState(() => _selectedSalesPersonId = v),
                validator: (v) => v == null ? 'Please select sales person' : null,
              ),

              const SizedBox(height: 24),
              const Text(
                'Location Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _latitude != null ? 'Lat: ${_latitude!.toStringAsFixed(6)}' : 'Latitude: Not set',
                              style: TextStyle(color: _latitude != null ? Colors.black87 : Colors.grey),
                            ),
                            Text(
                              _longitude != null ? 'Lng: ${_longitude!.toStringAsFixed(6)}' : 'Longitude: Not set',
                              style: TextStyle(color: _longitude != null ? Colors.black87 : Colors.grey),
                            ),
                          ],
                        ),
                        if (_isFetchingLocation)
                          const CircularProgressIndicator(color: Color(0xFF7C3AED))
                        else
                          ElevatedButton.icon(
                            onPressed: _getCurrentLocation,
                            icon: const Icon(Icons.location_on, size: 18),
                            label: Text(_latitude == null ? 'Fetch' : 'Refresh'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF7C3AED),
                              side: const BorderSide(color: Color(0xFF7C3AED)),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                      ],
                    ),
                    if (_locationFetchedAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Last fetched: ${DateFormat('HH:mm:ss').format(_locationFetchedAt!)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Ledger', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 12),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF374151)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, String? Function(String?)? validator, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5)),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: validator,
      keyboardType: keyboardType,
    );
  }

  Widget _buildDropdown({
    required dynamic value,
    required String hint,
    required List<DropdownMenuItem<dynamic>> items,
    required void Function(dynamic)? onChanged,
    String? Function(dynamic)? validator,
  }) {
    return DropdownButtonFormField<dynamic>(
      value: value,
      hint: Text(hint, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5)),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _selectDate,
      child: IgnorePointer(
        child: _buildTextField(_dateController, 'Select Date', null),
      ),
    );
  }
}
