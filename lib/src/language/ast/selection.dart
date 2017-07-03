import 'field.dart';
import 'fragment_spread.dart';
import 'inline_fragment.dart';
import 'node.dart';
import 'package:source_span/src/span.dart';

class SelectionContext extends Node {
  final FieldContext field;
  final FragmentSpreadContext fragmentSpread;
  final InlineFragmentContext inlineFragment;

  SelectionContext(this.field, [this.fragmentSpread, this.inlineFragment]) {
    assert(field != null || fragmentSpread != null || inlineFragment != null);
  }

  @override
  SourceSpan get span =>
      field?.span ?? fragmentSpread?.span ?? inlineFragment?.span;

  @override
  String toSource() =>
      field?.toSource() ??
      fragmentSpread?.toSource() ??
      inlineFragment?.toSource();
}