import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/slider/slider_basic.dart';
import 'package:example/docs/examples/slider/slider_controlled.dart';
import 'package:example/docs/examples/slider/slider_range.dart';
import 'package:example/docs/examples/slider/slider_steps.dart';
import 'package:example/docs/examples/slider/slider_value_indicator.dart';

final sliderDoc = ComponentDoc(
  slug: 'slider',
  title: 'Slider',
  description:
      'An input where the user selects a value from within a given range. '
      'Give `value` to hold it yourself or `initialValue` to let the '
      'slider keep it; `RangeSlider` has a thumb per value. '
      '`SliderFormField` puts a slider in a form.',
  examples: [
    ComponentExample(
      id: 'slider_basic',
      title: 'Default',
      builder: (_) => const SliderBasicExample(),
    ),
    ComponentExample(
      id: 'slider_range',
      title: 'Range',
      description:
          'RangeSlider takes one value per thumb. The values stay in '
          'ascending order — a thumb stops where its neighbour is rather '
          'than crossing it.',
      builder: (_) => const SliderRangeExample(),
    ),
    ComponentExample(
      id: 'slider_steps',
      title: 'Steps',
      description:
          'With divisions the slider snaps; set showDivisionMarks to false '
          'to snap without drawing the ticks.',
      builder: (_) => const SliderStepsExample(),
    ),
    ComponentExample(
      id: 'slider_value_indicator',
      title: 'Value indicator',
      description:
          '`valueIndicator` shows the value in a bubble above the thumb: '
          '`whileDragging` (also on hover and keyboard focus) or '
          '`always`. `valueLabel` formats it, for the bubble and for '
          'assistive technology. On a touch screen a stepped slider '
          'ticks at each stop.',
      builder: (_) => const SliderValueIndicatorExample(),
    ),
    ComponentExample(
      id: 'slider_controlled',
      title: 'Controlled',
      description:
          'With `value` the slider shows what the parent holds and '
          'reports a change without making it.',
      builder: (_) => const SliderControlledExample(),
    ),
  ],
);
