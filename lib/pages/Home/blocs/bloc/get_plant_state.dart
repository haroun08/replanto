part of 'get_plant_bloc.dart';

sealed class GetPlantState extends Equatable {
  const GetPlantState();
  
  @override
  List<Object> get props => [];
}

final class GetPlantInitial extends GetPlantState {}
