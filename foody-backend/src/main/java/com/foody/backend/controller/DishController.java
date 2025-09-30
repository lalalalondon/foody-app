package com.foody.backend.controller;

import com.foody.backend.model.Dish;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("/api/dishes")
public class DishController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @GetMapping
    public List<Dish> getAllDishes() {
        String sql = "SELECT * FROM dishes";
        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            Dish d = new Dish();
            d.setName(rs.getString("name"));
            d.setDescription(rs.getString("description"));
            d.setPrice(rs.getDouble("price"));
            d.setRestaurantName(rs.getString("restaurant_name"));
            d.setCategory(rs.getString("category"));
            d.setCalories(rs.getInt("calories"));
            return d;
        });
    }
}
