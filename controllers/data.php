<?php
if(!defined('IN_INDEX')) exit;

if(isset($_REQUEST['data_id']) && ($permission->granted(Permission::DATA_MANAGEMENT) || $permission->granted(Permission::DATA_ACCESS, intval($_REQUEST['data_id']), Permission::READ)))
 {
  include(BASE_PATH.'config/column_types.conf.php');
  $template->assign('column_types', $column_types);       
  
  if($table_info = get_table_info($_REQUEST['data_id'])) // 'true' fetches only overview columns
   { 
  switch($action)
   {
    case 'default':
     if(isset($_REQUEST['disable_map']))
      {
       $_REQUEST['disable_map'] = $_REQUEST['disable_map'] ? 1 : 0;
       set_user_setting();
      }
    
     if(isset($table_info['columns']))
      {
       $template->assign('columns', $table_info['columns']);
       $i=0;
       foreach($table_info['columns'] as $column)
        {
         if($column['type']>0)
          { 
           $column_names[] = $column['name'];
           $select_query_parts[] = 'table'.$table_info['table']['id'].'.'.$column['name'];
           #if($column['type']==1 || $column['type']==2 || $column['type']==3 || $column['type']==4 || $column['type']==5) 
           # {
             $filter_columns[$column['id']]['id'] = $column['id'];
             $filter_columns[$column['id']]['name'] = $column['name'];
             $filter_columns[$column['id']]['type'] = $column['type'];
             $filter_columns[$column['id']]['label'] = htmlspecialchars($column['label']);
           # }
          }
         if($column['relation'] && $column['relation_table_name'])
          {
           $joined_tables[] = $table_info['table']['id'];
           $joins[$i]['table'] = $table_info['table']['id'];
           $joins[$i]['alias'] = 'table'.$table_info['table']['id'].'_'.$i; // unique table alias
           $joins[$i]['relation_table'] = $column['relation_table'];
           $joins[$i]['relation_table_name'] = $column['relation_table_name'];
           $joins[$i]['relation_column_name'] = $column['name'];
           $joins[$i]['fk'] = $column['name'];
           $select_query_parts[] = 'table'.$table_info['table']['id'].'.'.$column['name'].' AS _'.$column['name'].'_';
           $select_query_parts[] = $joins[$i]['alias'].'.'.$column['relation_column_name'].' AS '.$column['name'];
          }       
         ++$i;
        }
       if(isset($select_query_parts)) $select_query = ', ' . implode(', ', $select_query_parts);
       else $select_query = '';
      } 
     else
      {
       $select_query = '';
      }
     
     if(isset($filter_columns)) $template->assign('filter_columns', $filter_columns);
     
     // check if table exists:
     $check_result = Database::$connection->query(LIST_TABLES_QUERY);
     foreach($check_result as $table)
      {
       $tables[] = $table['name'];
      }  

     if(in_array($table_info['table']['table_name'], $tables))
      {
       $template->assign('table_exists', true);
       
       $filter = isset($_GET['filter']) ? trim($_GET['filter']) : false;
       $filter_id = isset($_GET['filter_id']) ? intval($_GET['filter_id']) : 0;
       if($filter && $filter_id && isset($filter_columns[$filter_id]))
        {
         $template->assign('filter', htmlspecialchars($filter));
         $template->assign('filter_id', $filter_id);
        }
       else
        { 
         $filter = false; 
        }
        
       if($filter) $count_query = 'SELECT COUNT(*) FROM "'.$table_info['table']['table_name'].'" WHERE LOWER(CAST("'.$filter_columns[$filter_id]['name'].'" AS TEXT)) LIKE LOWER(:filter)';
       else $count_query = 'SELECT COUNT(*) FROM "'.$table_info['table']['table_name'].'"';
       $dbr = Database::$connection->prepare($count_query);
       if($filter) $dbr->bindValue(':filter', '%'.$filter.'%', PDO::PARAM_STR);
       $dbr->execute();
       list($total_items) = $dbr->fetch();
       
       if($table_info['table']['type']==1) // spatial data
        {
         $spatial_count_result = Database::$connection->query("SELECT COUNT(*) as total_items,
                                                   SUM(area) as total_area, ST_AsText(ST_Extent(geom)) as extent
                                                   FROM \"".$table_info['table']['table_name']."\"
                                                   WHERE geom IS NOT NULL");
         $row = $spatial_count_result->fetch();
         $spatial_info['count'] = $row['total_items'];
         $spatial_info['extent'] = $row['extent'];
         $spatial_info['area']['raw'] = $row['total_area'];
         $spatial_info['area']['sqm'] = number_format($row['total_area'], 1, $lang['dec_point'], $lang['thousands_sep']);
         $spatial_info['area']['ha'] = number_format($row['total_area']/10000, 1, $lang['dec_point'], $lang['thousands_sep']);      
         $spatial_info['area']['sqkm'] = number_format($row['total_area']/1000000, 1, $lang['dec_point'], $lang['thousands_sep']);
       
         #$total_count_result = Database::$connection->query("SELECT ST_AsText(ST_Extent(geom)) as extent FROM ".$table_info['table']['table_name']);
         #$row = $total_count_result->fetch();
         $template->assign('spatial_info', $spatial_info);
        }
       
       $items_per_page = isset($_GET['ipp']) ? intval($_GET['ipp']) : $settings['items_per_page'];
       if($items_per_page < 1) $items_per_page = $settings['items_per_page'];
       if($items_per_page > $settings['max_items_per_page']) $items_per_page = $settings['max_items_per_page'];
       $template->assign('ipp', $items_per_page);
       
       $total_pages = ceil($total_items / $items_per_page);
       
       // get current page:
       $p = isset($_GET['p']) ? intval($_GET['p']) : 1;
       if($p<1) $p=1;
       if($total_pages>0 && $p>$total_pages) $p = $total_pages;
       $template->assign('p', $p);
            
       $offset = ($p-1) * $items_per_page;
       
       $order = isset($_GET['order']) ? trim($_GET['order']) : 'created';
       $asc = isset($_GET['asc']) && $_GET['asc'] ? 1 : 0;
       
       $template->assign('order', htmlspecialchars($order));
       $template->assign('asc', $asc);
       
       if($table_info['table']['type']==1)
        {
         if(isset($column_names) && !in_array($order, $column_names) && $order!='fk' && $order!='created' && $order!='last_edited' && $order!='geom') $order = 'created';
        }
       else
        {
         if(isset($column_names) && !in_array($order, $column_names) && $order!='fk' && $order!='created' && $order!='last_edited') $order = 'created';
        }
      
       $descasc = $asc ? 'ASC' : 'DESC';
       
       $template->assign('total_items', $total_items);
       #$template->assign('displayed_items', $displayed_items);
       
       
       #if(isset($displayed_area)) $template->assign('displayed_area', $displayed_area);
       
       $template->assign('pagination', pagination($total_pages, $p));
  
       $query = "SELECT table".$table_info['table']['id'].".id,
                        table".$table_info['table']['id'].".fk,
                        extract(epoch FROM table".$table_info['table']['id'].".created) as created_timestamp,
                        userdata_table_1.name as creator,
                        extract(epoch FROM table".$table_info['table']['id'].".last_edited) as last_edited_timestamp,
                        table".$table_info['table']['id'].".last_editor as last_editor,
                        userdata_table_2.name as last_editor_name";
       if($table_info['table']['type']==1) $query .= ", CASE WHEN geom IS NULL THEN false ELSE true END AS has_geometry";
       $query .= $select_query;
       $query .= "\nFROM \"".$table_info['table']['table_name']."\" AS table".$table_info['table']['id'];
       if(isset($joins))
        {
         foreach($joins as $join)
          {
           $query .= "\nLEFT JOIN ".$join['relation_table_name']." AS ".$join['alias']." ON table".$table_info['table']['id'].".".$join['fk']."=".$join['alias'].".id";
          }
        }                                       
       
       $query .= "\nLEFT JOIN ".Database::$db_settings['userdata_table']." AS userdata_table_1 ON userdata_table_1.id=table".$table_info['table']['id'].".creator";
       $query .= "\nLEFT JOIN ".Database::$db_settings['userdata_table']." AS userdata_table_2 ON userdata_table_2.id=table".$table_info['table']['id'].".last_editor";
       
       if($filter) $query .= "\nWHERE LOWER(CAST(table".$table_info['table']['id'].".\"".$filter_columns[$filter_id]['name']."\" AS TEXT)) LIKE LOWER(:filter)";
       
       $query .= "\nORDER BY table".$table_info['table']['id'].".".$order." ".$descasc." LIMIT ".$items_per_page." OFFSET ".$offset;
       
       //showme($query);
        
       $dbr = Database::$connection->prepare($query);
       if($filter) $dbr->bindValue(':filter', '%'.$filter.'%', PDO::PARAM_STR);
       $dbr->execute();  

       $displayed_items = $dbr->rowCount();
       $template->assign('displayed_items', $displayed_items);
      
       $lang['displayed_records_label'] = str_replace('[total]', $total_items, str_replace('[displayed]', $displayed_items, $lang['displayed_records_label']));
       $lang['total_records_label'] = str_replace('[total]', $total_items, $lang['total_records_label']);
       
       $displayed_area_raw = 0;
       
       $i=0;
       $parent_group = 0;
       foreach($dbr as $row) 
        {
         // default columns:
         $data_items[$i]['id'] = intval($row['id']);
         $data_items[$i]['fk'] = intval($row['fk']);
         
         $data_items[$i]['creator'] = htmlspecialchars($row['creator']);
         $data_items[$i]['created'] = htmlspecialchars(strftime($lang['time_format'], $row['created_timestamp']));
         if(!is_null($row['last_editor'])) 
          {
           $data_items[$i]['last_editor'] = htmlspecialchars($row['last_editor_name']);
           $data_items[$i]['last_edited'] = htmlspecialchars(strftime($lang['time_format'], $row['last_edited_timestamp']));
          }
         // spatial data columns:
         if($table_info['table']['type']==1)
          {
           $data_items[$i]['has_geometry'] = $row['has_geometry'];
           #$displayed_area_raw += $row['area']; 
           #$data_items[$i]['wkt'] = $row['wkt'];
           #$data_items[$i]['area'] = $row['area'];
           #$data_items[$i]['area_sqm'] = number_format($row['area'], 1, $lang['dec_point'], $lang['thousands_sep']);
           #$data_items[$i]['area_ha'] = number_format($row['area']/10000, 1, $lang['dec_point'], $lang['thousands_sep']);
           #$data_items[$i]['perimeter'] = number_format($row['length'], 1, $lang['dec_point'], $lang['thousands_sep']);
          }                    
         // custom columns:
         if(isset($table_info['columns']))
          {
           foreach($table_info['columns'] as $column)
            {
             if($column['type']>0)
              { 
               // first custom column as feature label: 
               if($table_info['table']['type']==1 && empty($data_items[$i]['_featurelabel_'])) $data_items[$i]['_featurelabel_'] = htmlspecialchars($row[$column['name']]);
               $data_items[$i][$column['name']] = htmlspecialchars($row[$column['name']]);
              }
            }
          }
          ++$i;
        }
       
       if($displayed_area_raw)
        {
         $displayed_area['sqm'] = number_format($displayed_area_raw, 1, $lang['dec_point'], $lang['thousands_sep']);
         $displayed_area['ha'] = number_format($displayed_area_raw/10000, 1, $lang['dec_point'], $lang['thousands_sep']);
         $template->assign('displayed_area', $displayed_area);
        }
       
       if(isset($data_items)) $template->assign('data_items',$data_items);  
      
      
       #$dbr = Database::$connection->prepare("SELECT * FROM get_domains_n('".$table_info['table']['table_name']."', 'geom', 'id', 1400) AS g(gm text)");
       #$dbr->execute();
       #$row = $dbr->fetch();
       #foreach($dbr as $row)
       # {
       #  if($row['gm']!=NULL) $overview_features[] = $row['gm'];
       # }
       #if(isset($overview_features)) $template->assign('overview_features', $overview_features);
      }
     else
      {
       $template->assign('table_exists', false);
      } 
    
     $template->assign('table_id', intval($table_info['table']['id']));
     $template->assign('parent_table', intval($table_info['table']['parent_table']));
     $template->assign('parent_title', htmlspecialchars($table_info['table']['parent_title']));
     $template->assign('table_status', intval($table_info['table']['status']));
     $template->assign('readonly', $table_info['table']['readonly']);
     $template->assign('data_type', intval($table_info['table']['type']));
     $template->assign('geometry_type', intval($table_info['table']['geometry_type']));
     if($table_info['table']['default_latitude']) $template->assign('default_latitude', $table_info['table']['default_latitude']);
     #else $template->assign('default_latitude', $settings['default_latitude']);
     if($table_info['table']['default_longitude']) $template->assign('default_longitude', $table_info['table']['default_longitude']);
     #else $template->assign('default_longitude', $settings['default_longitude']);
     if($table_info['table']['default_zoomlevel']) $template->assign('default_zoomlevel', $table_info['table']['default_zoomlevel']);
     #else $template->assign('default_zoomlevel', $settings['default_zoomlevel']);
     $template->assign('min_scale', floatval($table_info['table']['min_scale']));
     $template->assign('max_scale', floatval($table_info['table']['max_scale']));
     $template->assign('max_resolution', floatval($table_info['table']['max_resolution']));
     if($table_info['table']['simplification_tolerance_extent_factor']) $template->assign('redraw', true);
     $template->assign('layer_overview', intval($table_info['table']['layer_overview']));
     $template->assign('auxiliary_layer_1', intval($table_info['table']['auxiliary_layer_1']));
     if($table_info['table']['auxiliary_layer_1_stef']) $template->assign('auxiliary_layer_1_redraw', true);
     $template->assign('auxiliary_layer_1_title', htmlspecialchars($table_info['table']['auxiliary_layer_1_title']));
     /*
     $template->assign('auxiliary_layer_2', intval($table_info['table']['auxiliary_layer_2']));
     $template->assign('auxiliary_layer_2_title', htmlspecialchars($table_info['table']['auxiliary_layer_2_title']));
     $template->assign('auxiliary_layer_3', intval($table_info['table']['auxiliary_layer_3']));
     $template->assign('auxiliary_layer_3_title', htmlspecialchars($table_info['table']['auxiliary_layer_3_title']));
     */
     $template->assign('subtitle', htmlspecialchars($table_info['table']['title']));
     $template->assign('description', nl2br(htmlspecialchars($table_info['table']['description'])));
     //$javascripts[] = JQUERY_UI;
     
     $granted_permissions['write'] = $table_info['table']['readonly']==0 && ($permission->granted(Permission::DATA_MANAGEMENT) || $permission->granted(Permission::DATA_ACCESS, intval($table_info['table']['id']), Permission::WRITE)) ? true : false;
     $granted_permissions['manage'] = $permission->granted(Permission::DATA_MANAGEMENT) || $permission->granted(Permission::DATA_ACCESS, intval($table_info['table']['id']), Permission::MANAGE) ? true : false;
     $granted_permissions['data_management'] = $permission->granted(Permission::DATA_MANAGEMENT) ? true : false;

     $template->assign('permission', $granted_permissions);
     
     if($permission->granted(Permission::DATA_MANAGEMENT) || $permission->granted(Permission::DATA_ACCESS, intval($table_info['table']['id']), Permission::MANAGE))
      {
       $javascripts[] = JQUERY_UI;
       $javascripts[] = JQUERY_UI_HANDLER;
      }
      
     if($table_info['table']['type']==1 && empty($_SESSION[$settings['session_prefix'].'usersettings']['disable_map']))
      {
       if($basemaps = get_basemaps($table_info['table']['basemaps']))
        {
         $template->assign('basemaps', $basemaps);
         foreach($basemaps as $basemap)
          {
           if($basemap['js'] && !in_array($basemap['js'], $javascripts)) $javascripts[] = $basemap['js'];
          }
        }
       $javascripts[] = OPENLAYERS;
       $javascripts[] = OPENLAYERS_DATA;
       #$javascripts[] = GOOGLE_MAPS;
       $stylesheets[] = OPENLAYERS_CSS;
       if($table_info['table']['parent_table']) $template->assign('help', 'data_spatial_child');
       else $template->assign('help', 'data_spatial');
      }
     else
      {
       if($table_info['table']['parent_table']) $template->assign('help', 'data_common_child');
       else $template->assign('help', 'data_common');
      }
     
        /* images: */
        if($settings['data_images'] && $table_info['table']['data_images'])
         {
          // get images:
          $dbr = Database::$connection->prepare("SELECT id, filename, thumbnail_width, thumbnail_height, title, description, author FROM ".Database::$db_settings['data_images_table']." WHERE data=:data AND item=:item ORDER by sequence ASC");
          $dbr->bindParam(':data', $table_info['table']['id'], PDO::PARAM_INT);
          $dbr->bindValue(':item', 0, PDO::PARAM_INT);
          $dbr->execute();
          $i=0;
          while($row = $dbr->fetch())
           {
            $images[$i]['id'] = $row['id'];
            $images[$i]['filename'] = $row['filename'];
            if($settings['data_images_permission_check'])
             {
              $images[$i]['thumbnail_url'] = BASE_URL.'?r=data_image.thumbnail&file='.$row['filename'];
              $images[$i]['image_url'] = BASE_URL.'?r=data_image.image&file='.$row['filename'];
             }
            else
             {
              $images[$i]['thumbnail_url'] = DATA_THUMBNAILS_URL.$row['filename'];
              $images[$i]['image_url'] = DATA_IMAGES_URL.$row['filename'];
             }
            $images[$i]['thumbnail_width'] = intval($row['thumbnail_width']);
            $images[$i]['thumbnail_height'] = intval($row['thumbnail_height']);
            $images[$i]['title'] = htmlspecialchars($row['title']);
            $images[$i]['description'] = htmlspecialchars($row['description']);
            if($row['author']) $images[$i]['author'] = str_replace('[author]', htmlspecialchars($row['author']), $lang['gallery_image_author_declaration']);
            else $images[$i]['author'] = '';
            ++$i;
           }
          // enable images if there are images or if user is allowed to add images:
          if($i || $granted_permissions['write'])
           {
            $lang['data_images'] = str_replace('[number]', $i, $lang['data_images']);
            $template->assign('number_of_images', $i); 
            $template->assign('data_images', true);
           }
          // assign images and requirements:
          if(isset($images))
           {
            $template->assign('images', $images);    
            $javascripts[] = LIGHTBOX;
            if($granted_permissions['write'])
             {
              if(empty($javascripts) || (isset($javascripts) && !in_array(JQUERY_UI, $javascripts))) $javascripts[] = JQUERY_UI;
              if(empty($javascripts) || (isset($javascripts) && !in_array(JQUERY_UI_HANDLER, $javascripts))) $javascripts[] = JQUERY_UI_HANDLER;
             }
           }
         }     
     
     
     $template->assign('subtemplate', 'data.inc.tpl');
     break;
   
   case 'delete':
    if(isset($_REQUEST['id']) && isset($table_info['table']['id']) && ($permission->granted(Permission::DATA_MANAGEMENT) || $permission->granted(Permission::DATA_ACCESS, $table_info['table']['id'], Permission::WRITE)))
     {
      $dbr = Database::$connection->prepare("SELECT id, fk
                                             FROM \"".$table_info['table']['table_name']."\"
                                             WHERE id=:id
                                             LIMIT 1");
      $dbr->bindParam(':id', $_REQUEST['id'], PDO::PARAM_INT);
      $dbr->execute();
      $row = $dbr->fetch();
      if(isset($row['id']))
       {
        if(empty($_REQUEST['confirmed']))
         {
          if($table_info['table']['parent_table'] && $row['fk']) $template->assign('back', BASE_URL.'?r=data_item&data_id='.$table_info['table']['parent_table'].'&id='.$row['fk'].'#attached-data');
          else $template->assign('back', BASE_URL.'?r=data&data_id='.$table_info['table']['id']);
          $template->assign('data_id', $table_info['table']['id']);
          $template->assign('r', 'data.delete');
          $template->assign('id', $row['id']); 
          $template->assign('subtitle', $lang['delete_confirm_subtitle']);
          $template->assign('delete_message', 'delete_data_item_message');
          $template->assign('subtemplate', 'delete_confirm.inc.tpl');
         }
        else
         {
          // get current data for the activity log:
          $dbr = Database::$connection->prepare('SELECT * FROM "'.$table_info['table']['table_name'].'" WHERE id=:id LIMIT 1');
          $dbr->bindParam(':id', $row['id'], PDO::PARAM_INT);
          $dbr->execute();
          $previous_data = serialize($dbr->fetch(PDO::FETCH_ASSOC));          
          
          // delete item:
          $dbr = Database::$connection->prepare("DELETE FROM \"".$table_info['table']['table_name']."\" WHERE id = :id");
          $dbr->bindValue(':id', $row['id']);
          $dbr->execute();
          
          delete_linked_data($table_info['table']['id'], $row['id']);
          log_activity(ACTIVITY_DELETE_ITEM, $table_info['table']['id'], $row['id'], $previous_data);
          
          if($table_info['table']['parent_table'] && $row['fk']) header('Location: '.BASE_URL.'?r=data_item&data_id='.$table_info['table']['parent_table'].'&id='.$row['fk'].'#attached-data');
          else header('Location: '.BASE_URL.'?r=data&data_id='.$table_info['table']['id']);
          exit;
         }
       }
      else // item not available
       {
        header('Location: '.BASE_URL.'?r=data&id='.$table_info['table']['id']);
        exit;
       }  
     }      
    break;
    

    case 'definition':
     // get model and item data:
     $dbr = Database::$connection->prepare("SELECT items.id,
                                                   items.table_id,
                                                   items.name,
                                                   items.label,
                                                   items.description,
                                                   items.definition
                                            FROM ".Database::$db_settings['data_model_items_table']." AS items
                                            WHERE items.id=:id LIMIT 1");
     $dbr->bindParam(':id', $_REQUEST['id'], PDO::PARAM_INT);
     $dbr->execute();
     $row = $dbr->fetch();
     // check permission:
     if(isset($row['table_id']) && ($permission->granted(Permission::DATA_ACCESS, $row['table_id'], Permission::READ)))
      {    
       $template->assign('label', htmlspecialchars($row['label']));
       $template->assign('definition', nl2br(htmlspecialchars($row['definition'])));
       $page_template = 'subtemplates/data_definition.inc.tpl';  
      }
    break;
   
   }
 
   }
  else
   {
    $http_status = 404;
   }
 
 }
else
 {
  $http_status = 403;
 } 
?>
