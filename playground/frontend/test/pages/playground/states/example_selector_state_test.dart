/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:playground_components/src/models/example_base.dart';
import 'package:playground_components/src/controllers/example_loaders/examples_loader.dart';
import 'package:playground/pages/playground/states/example_selector_state.dart';
import 'package:playground_components/src/cache/example_cache.dart';
import 'package:playground_components/src/controllers/playground_controller.dart';

import 'example_selector_state_test.mocks.dart';
import '../../../../playground_components/test/src/common/categories.dart';
import '../../../../playground_components/test/src/common/example_repository_mock.dart';

@GenerateMocks([ExamplesLoader])
void main() {
  late PlaygroundController playgroundController;
  late ExampleCache exampleCache;
  late ExampleSelectorState state;
  final mockExampleRepository = getMockExampleRepository();

  setUp(() {
    exampleCache = ExampleCache(
      exampleRepository: mockExampleRepository,
      hasCatalog: true,
    );

    playgroundController = PlaygroundController(
      examplesLoader: MockExamplesLoader(),
      exampleCache: exampleCache,
    );
    state = ExampleSelectorState(playgroundController, []);
  });

  test(
    'ExampleSelector state selectedFilterType should be ExampleType.all by default',
    () {
      expect(state.selectedFilterType, ExampleType.all);
    },
  );

  test(
    'ExampleSelector state filterText should be empty string by default',
    () {
      expect(state.filterText, '');
    },
  );

  test(
    'ExampleSelector state should notify all listeners about filter type change',
    () {
      state.addListener(() {
        expect(state.selectedFilterType, ExampleType.example);
      });
      state.setSelectedFilterType(ExampleType.example);
    },
  );

  test(
    'ExampleSelector state should notify all listeners about filterText change',
    () {
      state.addListener(() {
        expect(state.filterText, 'test');
      });
      state.setFilterText('test');
    },
  );

  test(
    'ExampleSelector state should notify all listeners about categories change',
    () {
      state.addListener(() {
        expect(state.categories, []);
      });
      state.setCategories([]);
    },
  );

  test(
      'ExampleSelector state sortCategories should:'
      '- update categories and notify all listeners,'
      'but should NOT:'
      '- affect Example state categories', () {
    state.addListener(() {
      expect(state.categories, []);
      expect(exampleCache.categoryListsBySdk, exampleCache.categoryListsBySdk);
    });
    state.sortCategories();
  });

  test(
      'ExampleSelector state sortExamplesByType should:'
      '- update categories,'
      '- notify all listeners,'
      'but should NOT:'
      '- affect Example state categories', () {
    final state = ExampleSelectorState(
      playgroundController,
      categoriesMock,
    );
    state.addListener(() {
      expect(state.categories, examplesSortedByTypeMock);
      expect(exampleCache.categoryListsBySdk, exampleCache.categoryListsBySdk);
    });
    state.sortExamplesByType(unsortedExamples, ExampleType.kata);
  });

  test(
      'ExampleSelector state sortExamplesByName should:'
      '- update categories'
      '- notify all listeners,'
      'but should NOT:'
      '- wait for full name of example,'
      '- be sensitive for register,'
      '- affect Example state categories', () {
    final state = ExampleSelectorState(
      playgroundController,
      categoriesMock,
    );
    state.addListener(() {
      expect(state.categories, examplesSortedByNameMock);
      expect(exampleCache.categoryListsBySdk, exampleCache.categoryListsBySdk);
    });
    state.sortExamplesByName(unsortedExamples, 'X1');
  });
}
