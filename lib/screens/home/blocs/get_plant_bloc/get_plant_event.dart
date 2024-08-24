part of 'get_plant_bloc.dart';

sealed class GetPlantEvent extends Equatable {
  const GetPlantEvent();

  @override
  List<Object> get props => [];
}
final class GetPlant extends GetPlantEvent {}


