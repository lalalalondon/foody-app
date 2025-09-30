package com.foody.backend.controller;

import com.foody.backend.model.Restaurant;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("/api/restaurants")
public class RestaurantController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @GetMapping
    public List<Restaurant> getAllRestaurants() {
        String sql = "SELECT * FROM restaurants";
        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            Restaurant r = new Restaurant();
            r.setName(rs.getString("name"));
            r.setAddress(rs.getString("address"));
            r.setPhone(rs.getString("phone"));
            return r;
        });
    }

    @PostMapping
    public Restaurant addRestaurant(@RequestBody Restaurant restaurant) {
        String sql = "INSERT INTO restaurants (name, address, phone) VALUES (?, ?, ?)";
        jdbcTemplate.update(sql, restaurant.getName(), restaurant.getAddress(), restaurant.getPhone());
        return restaurant;
    }
}
