import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../data/models/contact_model.dart';
import '../../../data/repositories/contacts_repository.dart';
import '../../../shared/widgets/async_state_views.dart';
import '../admin_common.dart';

class AdminContactsScreen extends StatefulWidget {
  const AdminContactsScreen({super.key});

  @override
  State<AdminContactsScreen> createState() => _AdminContactsScreenState();
}

class _AdminContactsScreenState extends State<AdminContactsScreen> {
  final ContactsRepository _repository = ContactsRepository();
  List<CommunityContact> _contacts = const [];
  bool _loading = true;
  String? _error;
  final Set<int> _deleting = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final contacts = await _repository.fetchContacts();
      if (!mounted) return;
      setState(() {
        _contacts = contacts;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    }
  }

  Future<void> _openForm([CommunityContact? contact]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _ContactForm(repository: _repository, contact: contact),
      ),
    );
    if (saved == true) _load();
  }

  Future<void> _delete(CommunityContact contact) async {
    if (!await confirmAdminDelete(context, contact.name)) return;
    setState(() => _deleting.add(contact.id));
    try {
      await _repository.delete(contact.id);
      if (!mounted) return;
      setState(() => _contacts = _contacts.where((c) => c.id != contact.id).toList());
      showAdminSuccess(context, '${contact.name} deleted.');
    } catch (e) {
      if (mounted) handleAdminError(context, e);
    } finally {
      if (mounted) setState(() => _deleting.remove(contact.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: adminBackground,
      appBar: buildAdminAppBar('Contacts', onRefresh: _loading ? null : _load),
      floatingActionButton: _loading || _error != null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openForm(),
              backgroundColor: adminPrimary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add contact'),
            ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingStateView();
    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [ErrorStateView(message: _error!, onRetry: _load)],
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          const AdminHeaderCard(
            icon: Icons.contact_phone_outlined,
            title: 'Community Contacts',
            subtitle: 'Numbers are shown to residents as plain text. Water and Shuttle contacts appear on those screens.',
          ),
          if (_contacts.isEmpty)
            const EmptyStateView(
              icon: Icons.contact_phone_outlined,
              title: 'No contacts yet',
              message: 'Tap "Add contact" to create the first number.',
            ),
          for (final category in ContactCategory.all) ..._buildCategory(category),
        ],
      ),
    );
  }

  List<Widget> _buildCategory(String category) {
    final items = _contacts.where((c) => c.category == category).toList();
    if (items.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
        child: Text(
          category,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: adminPrimary),
        ),
      ),
      for (final contact in items)
        Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              [contact.phoneNumber, contact.secondaryNumber, contact.description]
                  .whereType<String>()
                  .join('\n'),
            ),
            isThreeLine: contact.secondaryNumber != null ||
                (contact.phoneNumber != null && contact.description != null),
            onTap: () => _openForm(contact),
            trailing: _deleting.contains(contact.id)
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    tooltip: 'Delete',
                    icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                    onPressed: () => _delete(contact),
                  ),
          ),
        ),
    ];
  }
}

class _ContactForm extends StatefulWidget {
  final ContactsRepository repository;
  final CommunityContact? contact;

  const _ContactForm({required this.repository, required this.contact});

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  static final RegExp _phonePattern = RegExp(r'^[0-9+\-\s()]{3,30}$');

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _phone;
  late final TextEditingController _secondary;
  late final TextEditingController _sortOrder;
  late String _category;
  bool _saving = false;

  bool get _isEdit => widget.contact != null;

  @override
  void initState() {
    super.initState();
    final c = widget.contact;
    _name = TextEditingController(text: c?.name ?? '');
    _description = TextEditingController(text: c?.description ?? '');
    _phone = TextEditingController(text: c?.phoneNumber ?? '');
    _secondary = TextEditingController(text: c?.secondaryNumber ?? '');
    _sortOrder = TextEditingController(text: '${c?.sortOrder ?? 1}');
    _category = c?.category ?? ContactCategory.emergency;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _phone.dispose();
    _secondary.dispose();
    _sortOrder.dispose();
    super.dispose();
  }

  String? _optional(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  String? _validatePhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    return _phonePattern.hasMatch(text)
        ? null
        : 'Use only digits, spaces, +, -, and brackets.';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final contact = CommunityContact(
      id: widget.contact?.id ?? 0,
      category: _category,
      name: _name.text.trim(),
      description: _optional(_description),
      phoneNumber: _optional(_phone),
      secondaryNumber: _optional(_secondary),
      sortOrder: int.parse(_sortOrder.text.trim()),
    );
    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await widget.repository.update(contact);
      } else {
        await widget.repository.create(contact);
      }
      if (!mounted) return;
      showAdminSuccess(context, '${contact.name} saved.');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) handleAdminError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _decoration(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: adminBackground,
      appBar: buildAdminAppBar(_isEdit ? 'Edit Contact' : 'New Contact'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: _decoration('Category'),
              items: [
                for (final c in ContactCategory.all) DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: _saving ? null : (v) => setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              enabled: !_saving,
              maxLength: 100,
              decoration: _decoration('Name', hint: 'Police Dispatch'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name.' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phone,
              enabled: !_saving,
              keyboardType: TextInputType.phone,
              decoration: _decoration('Phone number (optional)', hint: '0311-7773997'),
              validator: _validatePhone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _secondary,
              enabled: !_saving,
              keyboardType: TextInputType.phone,
              decoration: _decoration('Second number (optional)'),
              validator: _validatePhone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              enabled: !_saving,
              maxLength: 200,
              decoration: _decoration('Note (optional)', hint: 'Shown when there is no number'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _sortOrder,
              enabled: !_saving,
              keyboardType: TextInputType.number,
              decoration: _decoration('Display order'),
              validator: (v) {
                final n = int.tryParse(v?.trim() ?? '');
                return (n == null || n < 0 || n > 1000) ? 'Enter a number from 0 to 1000.' : null;
              },
            ),
            const SizedBox(height: 24),
            AdminSaveButton(saving: _saving, label: 'Save Contact', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
