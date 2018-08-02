import 'package:graphql_parser/graphql_parser.dart';
import 'package:matcher/matcher.dart';
import 'package:test/test.dart';
import 'argument_test.dart';
import 'common.dart';

main() {
  test('name only', () {
    expect('@foo', isDirective('foo'));
  });

  test('with value or variable', () {
    expect('@foo: 2', isDirective('foo', valueOrVariable: equals(2)));
    expect(r'@foo: $bar', isDirective('foo', valueOrVariable: equals('bar')));
  });

  test('with argument', () {
    expect('@foo (bar: 2)', isDirective('foo', argument: isArgument('bar', 2)));
    expect(r'@foo (bar: $baz)',
        isDirective('foo', argument: isArgument('bar', r'baz')));
  });

  test('exceptions', () {
    expect(() => parseDirective('@'), throwsSyntaxError);
    expect(() => parseDirective('@foo:'), throwsSyntaxError);
    expect(() => parseDirective('@foo ('), throwsSyntaxError);
    expect(() => parseDirective('@foo (bar: 2'), throwsSyntaxError);
    expect(() => parseDirective('@foo ()'), throwsSyntaxError);
  });
}

DirectiveContext parseDirective(String text) => parse(text).parseDirective();

Matcher isDirective(String name, {Matcher valueOrVariable, Matcher argument}) =>
    new _IsDirective(name,
        valueOrVariable: valueOrVariable, argument: argument);

Matcher isDirectiveList(List<Matcher> directives) =>
    new _IsDirectiveList(directives);

class _IsDirective extends Matcher {
  final String name;
  final Matcher valueOrVariable, argument;

  _IsDirective(this.name, {this.valueOrVariable, this.argument});

  @override
  Description describe(Description description) {
    var desc = description.add('is a directive with name "$name"');

    if (valueOrVariable != null) {
      return valueOrVariable.describe(desc.add(' and '));
    } else if (argument != null) {
      return argument.describe(desc.add(' and '));
    } else
      return desc;
  }

  @override
  bool matches(item, Map matchState) {
    var directive = item is DirectiveContext ? item : parseDirective(item);
    if (directive == null) return false;
    if (valueOrVariable != null) {
      if (directive.valueOrVariable == null)
        return false;
      else
        return valueOrVariable.matches(
            directive.valueOrVariable.value?.value ??
                directive.valueOrVariable.variable?.name,
            matchState);
    } else if (argument != null) {
      if (directive.argument == null)
        return false;
      else
        return argument.matches(directive.argument, matchState);
    } else
      return true;
  }
}

class _IsDirectiveList extends Matcher {
  final List<Matcher> directives;

  _IsDirectiveList(this.directives);

  @override
  Description describe(Description description) {
    return description.add('is list of ${directives.length} directive(s)');
  }

  @override
  bool matches(item, Map matchState) {
    var args =
        item is List<DirectiveContext> ? item : parse(item).parseDirectives();

    if (args.length != directives.length) return false;

    for (int i = 0; i < args.length; i++) {
      if (!directives[i].matches(args[i], matchState)) return false;
    }

    return true;
  }
}