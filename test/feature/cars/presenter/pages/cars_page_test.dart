import 'package:clean_cars/feature/cars/domain/entities/cars_entity.dart';
import 'package:clean_cars/feature/cars/domain/failures/failures.dart';
import 'package:clean_cars/feature/cars/domain/usecases/get_cars_usecase.dart';
import 'package:clean_cars/feature/cars/presenter/cubits/cars_cubit.dart';
import 'package:clean_cars/feature/cars/presenter/pages/cars_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

class GetCarsUsecaseMock extends Mock implements GetCarsUsecase {}

void main() {
  late GetCarsUsecaseMock getCarsUsecaseMock;

  setUp(() {
    getCarsUsecaseMock = GetCarsUsecaseMock();
  });

  Widget createWidgetTest() {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => CarsCubit(
          getCarsUsecase: getCarsUsecaseMock,
        )..getCars(),
        child: const CarsPage(),
      ),
    );
  }

  testWidgets('Deve mostrar a AppBar da pagina', (tester) async {
    //Arrange
    when(() => getCarsUsecaseMock.call()).thenAnswer(
      (_) async => [
        CarsEntity(
          id: 13301,
          nome: "Ford Mustang 1976 BBB",
          tipo: "classicos",
          descricao: "Desc Ford Mustang 1976fwsafdfasd",
          urlFoto:
              "https://s3-sa-east-1.amazonaws.com/videos.livetouchdev.com.br/classicos/Ford_Mustang.png",
          urlVideo:
              "https://s3-sa-east-1.amazonaws.com/videos.livetouchdev.com.br/classicos/ford_mustang.mp4",
          latitude: "-23.564224",
          longitude: "-46.653156",
        ),
      ],
    );

    await tester.pumpWidget(createWidgetTest());

    final carsAppBar = find.byKey(const Key('carlist-app-bar'));

    expect(carsAppBar, findsOneWidget);

    verify(() => getCarsUsecaseMock.call()).called(1);
    verifyNoMoreInteractions(getCarsUsecaseMock);
  });

  testWidgets('''Quando o usecase for sucedido:
    1) Inicia a tela mostrando um CircularProgress Indicator.
    2) Mostra a lista de filmes.
    ''', (tester) async {
    //Arrange
    when(() => getCarsUsecaseMock.call()).thenAnswer(
      (_) async {
        await Future.delayed(const Duration(seconds: 1));
        return [
          CarsEntity(
            id: 13301,
            nome: "Ford Mustang 1976 BBB",
            tipo: "classicos",
            descricao: "Desc Ford Mustang 1976fwsafdfasd",
            urlFoto:
                "https://s3-sa-east-1.amazonaws.com/videos.livetouchdev.com.br/classicos/Ford_Mustang.png",
            urlVideo:
                "https://s3-sa-east-1.amazonaws.com/videos.livetouchdev.com.br/classicos/ford_mustang.mp4",
            latitude: "-23.564224",
            longitude: "-46.653156",
          ),
        ];
      },
    );

    // Mockar testes que tentam carregar imagens da web
    await mockNetworkImages(() async {
      await tester.pumpWidget(createWidgetTest());

      //Encontrar o CircularProgressIndicator
      final circularProgressIndicator = find.byKey(
        const Key('circular-progress-indicator'),
      );

      expect(circularProgressIndicator, findsOneWidget);

      //Aguardando termino da animação do CircularProgressIndicator
      await tester.pumpAndSettle();

      //Encontrar a Lista de cars
      final cars = find.byKey(const Key('cars-list'));

      expect(cars, findsOneWidget);

      verify(() => getCarsUsecaseMock.call()).called(1);
      verifyNoMoreInteractions(getCarsUsecaseMock);
    });
  });

  testWidgets('''
    Quando o usecase lançar um subtipo de CarsFailure:
    1) Mostra a mensagem de erro na tela.
    ''', (tester) async {
    //Arrange
    when(() => getCarsUsecaseMock.call()).thenThrow(UnknownCarsFailure());

    await tester.pumpWidget(createWidgetTest());

    final errorMessage = find.byKey(const Key('cars-error-message'));

    expect(errorMessage, findsOneWidget);

    verify(() => getCarsUsecaseMock.call()).called(1);
    verifyNoMoreInteractions(getCarsUsecaseMock);
  });
}
