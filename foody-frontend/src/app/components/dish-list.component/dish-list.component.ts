import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClient, HttpClientModule } from '@angular/common/http';

@Component({
  selector: 'app-dish-list',
  standalone: true,
  imports: [CommonModule, HttpClientModule],
  templateUrl: './dish-list.component.html',
  styleUrl: './dish-list.component.css'
})
export class DishListComponent implements OnInit {
  dishes: any[] = [];

  constructor(private http: HttpClient) {}

  ngOnInit() {
    this.http.get<any[]>('http://localhost:9090/api/dishes')
      .subscribe(data => {
        this.dishes = data;
      });
  }
}
