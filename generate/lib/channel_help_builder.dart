
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';
import 'channel_help_generator.dart';

Builder nativeCallBuilder(BuilderOptions options) =>
    LibraryBuilder(ChannelHelpGenerator(), generatedExtension: '.nc.g.dart');