
import { DishListComponent } from './components/dish-list.component/dish-list.component';
import { Routes } from '@angular/router';

export const routes: Routes = [
  { path: '', redirectTo: '/dishes', pathMatch: 'full' },
  { path: 'dishes', component: DishListComponent },

];
