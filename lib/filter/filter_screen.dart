import 'package:flutter/material.dart';

class FilterOptions {
  final String type;
  final String price;

  FilterOptions({required this.type, required this.price});
}

class FilterWidget extends StatefulWidget {
  final Function(FilterOptions) onFiltersChanged;

  FilterWidget({required this.onFiltersChanged});

  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  bool _isFilterOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isFilterOpen = !_isFilterOpen;
            });
          },
          child: Row(
            children: [
              Icon(
                _isFilterOpen ? Icons.filter_list_alt : Icons.filter_alt,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(_isFilterOpen ? 'Cerrar Filtros' : 'Abrir Filtros'),
            ],
          ),
        ),
        if (_isFilterOpen) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Filtrar por tipo:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DropdownButton<String>(
            value: 'ALL',
            onChanged: (value) {
              widget.onFiltersChanged(FilterOptions(type: value ?? '', price: ''));
            },
            items: <String>['ALL', 'VEGAN']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Filtrar por precio:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FilterButton(
                label: '\$',
                onPressed: () {
                  widget.onFiltersChanged(FilterOptions(type: 'ALL', price: '\$'));
                },
              ),
              FilterButton(
                label: '\$\$',
                onPressed: () {
                  widget.onFiltersChanged(FilterOptions(type: 'ALL', price: '\$\$'));
                },
              ),
              FilterButton(
                label: '\$\$\$',
                onPressed: () {
                  widget.onFiltersChanged(FilterOptions(type: 'ALL', price: '\$\$\$'));
                },
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const FilterButton({
    Key? key,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black, backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
      ),
    );
  }
}
