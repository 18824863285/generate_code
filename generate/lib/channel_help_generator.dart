import 'package:analyzer/dart/element/element.dart';
import 'package:annotations/channel_help.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as Path;
import 'package:build/build.dart';

class ChannelHelpGenerator extends GeneratorForAnnotation<ChannelHelp> {
  static final String channelName = "_MethodChannel";

  String className;

  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final emitter = DartEmitter();

    if (element is! ClassElement) {
      throw InvalidGenerationSourceError('ChannelHelper只能用在类上');
    }
    className = element.displayName;
    var channelName = annotation.peek("channelName").stringValue;
    ClassBuilder classBuilder;

    var channelHelper = Class((builder) {
      classBuilder = builder;

      classBuilder.constructors.add(Constructor((constructorBuild) {
        constructorBuild.name = "_internal";
      }));

      classBuilder.name = '${className}Imp';
      classBuilder.implements.add(refer(className));
      classBuilder.fields.add(Field((fieldBuild) {
        fieldBuild.name = "_MethodChannel";
        fieldBuild.type = refer("MethodChannel");
        fieldBuild.modifier = FieldModifier.final$;
        fieldBuild.assignment = Code('MethodChannel("$channelName")');
      }));

      classBuilder.fields.add(Field((fieldBuild) {
        fieldBuild.name = "_$className";
        fieldBuild.type = refer("$className");
        fieldBuild.static = true;
      }));

      classBuilder.methods.add(Method((methodBuild) {
        methodBuild.name = "getInstance";
        methodBuild.returns = refer('$className');
        methodBuild.static = true;
        methodBuild.body = _generatorSingleInstantBody();
      }));

      ClassElement classElement = element as ClassElement;
      List<MethodElement> methodElements = classElement.methods;
      if (methodElements != null && methodElements.length > 0) {
        methodElements.forEach((methodElement) {
          classBuilder.methods.add(Method((methodBuild) {
            methodBuild.name = methodElement.name;
            methodBuild.modifier = MethodModifier.async;
            methodBuild.returns =
                refer("${methodElement.returnType.getDisplayString()}");
            methodBuild.annotations.add(TypeReference((build) {
              // 给方法添加注解
              build.symbol = "override"; //注解类型是override
            }));
            var parameters = methodElement.parameters;
            methodBuild.body = _generatorBody(methodElement, parameters);
          }));
        });
      }
    });

    String channelHelperStr =
        DartFormatter().format('${channelHelper.accept(emitter)}');

    return """
        
        part of '${Path.basename(buildStep.inputId.path)}';
        
        $channelHelperStr
    """;
  }

  Code _generatorSingleInstantBody() {
    final blocks = <Code>[];
    blocks.add(Code("if(_$className == null) {"));
    blocks
        .add(Code("_$className = ${className}Imp._internal() as $className;"));
    blocks.add(Code("}"));
    blocks.add(Code("return _$className;"));
    return Block.of(blocks);
  }

  // ignore: missing_return
  Code _generatorBody(
      MethodElement methodElement, List<ParameterElement> parameters) {
    final blocks = <Code>[];
    if (parameters == null || parameters.length == 0) {
      blocks.add(Code(
          "dynamic _result = await $channelName.invokeMethod('${methodElement.name}');"));
    }
    blocks.add(_generatorResult(methodElement));
    return Block.of(blocks);
  }

  Code _generatorResult(MethodElement methodElement) {
    final blocks = <Code>[];
    return Block.of(blocks);
  }
}
