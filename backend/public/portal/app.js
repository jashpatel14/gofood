/**
 * GoFood Zomato-Style Partner & Admin Portal
 * Pure SPA Frontend Business Logic
 */

// Global State Management
const state = {
  token: localStorage.getItem('gofood_token') || null,
  role: localStorage.getItem('gofood_role') || null,
  user: JSON.parse(localStorage.getItem('gofood_user')) || null,
  restaurant: null,
  orders: [],
  foods: [],
  partners: [],
  pollingInterval: null,
  activeTab: 'login' // 'login' or 'register'
};

// API Base Path
const API_BASE = '/api';

// Toast Notification Utility
function showToast(message, isSuccess = true) {
  const toast = document.getElementById('toast');
  const icon = document.getElementById('toast-icon');
  const msgText = document.getElementById('toast-msg');

  msgText.textContent = message;
  if (isSuccess) {
    toast.style.borderLeftColor = 'var(--success)';
    icon.textContent = 'check_circle';
    icon.style.color = 'var(--success)';
  } else {
    toast.style.borderLeftColor = 'var(--danger)';
    icon.textContent = 'error';
    icon.style.color = 'var(--danger)';
  }

  toast.classList.remove('hidden');
  
  // Auto-hide toast after 4 seconds
  if (toast.timeoutId) clearTimeout(toast.timeoutId);
  toast.timeoutId = setTimeout(() => {
    toast.classList.add('hidden');
  }, 4000);
}

// Global API Fetch wrapper with Auth headers
async function fetchAPI(endpoint, options = {}) {
  const headers = {
    'Content-Type': 'application/json',
    ...(options.headers || {})
  };

  if (state.token) {
    headers['Authorization'] = `Bearer ${state.token}`;
  }

  const response = await fetch(`${API_BASE}${endpoint}`, {
    ...options,
    headers
  });

  const data = await response.json();
  if (!response.ok) {
    throw new Error(data.error || 'Something went wrong');
  }
  return data;
}

// Router & View Switcher
function swapView() {
  const mainHeader = document.getElementById('main-header');
  const authContainer = document.getElementById('auth-container');
  const partnerWorkspace = document.getElementById('partner-workspace');
  const adminWorkspace = document.getElementById('admin-workspace');

  // Clear any existing order polling
  if (state.pollingInterval) {
    clearInterval(state.pollingInterval);
    state.pollingInterval = null;
  }

  if (!state.token) {
    // Unauthenticated
    mainHeader.classList.add('hidden');
    authContainer.classList.remove('hidden');
    partnerWorkspace.classList.add('hidden');
    adminWorkspace.classList.add('hidden');
    initAuthView();
  } else {
    // Authenticated
    authContainer.classList.add('hidden');
    mainHeader.classList.remove('hidden');

    // Update Profile Information in Header
    document.getElementById('user-name').textContent = state.user.name;
    document.getElementById('user-email').textContent = state.user.email;
    
    const roleBadge = document.getElementById('role-badge');
    roleBadge.textContent = state.role === 'admin' ? 'Admin' : 'Partner';

    if (state.role === 'admin') {
      partnerWorkspace.classList.add('hidden');
      adminWorkspace.classList.remove('hidden');
      loadAdminDashboard();
    } else {
      adminWorkspace.classList.add('hidden');
      partnerWorkspace.classList.remove('hidden');
      loadPartnerDashboard();
    }
  }
}

// Initialize Auth View and form handlers
function initAuthView() {
  const tabLogin = document.getElementById('tab-login');
  const tabRegister = document.getElementById('tab-register');
  const groupName = document.getElementById('group-name');
  const groupPhone = document.getElementById('group-phone');
  const authSubmit = document.getElementById('auth-submit');
  const authSubtitle = document.getElementById('auth-subtitle');
  const authForm = document.getElementById('auth-form');

  // Reset inputs
  authForm.reset();

  tabLogin.onclick = () => {
    state.activeTab = 'login';
    tabLogin.classList.add('active');
    tabRegister.classList.remove('active');
    groupName.style.display = 'none';
    groupPhone.style.display = 'none';
    authSubmit.textContent = 'Sign In';
    authSubtitle.textContent = 'Log in to manage your restaurant listings and active orders.';
    document.getElementById('auth-name').removeAttribute('required');
    document.getElementById('auth-phone').removeAttribute('required');
  };

  tabRegister.onclick = () => {
    state.activeTab = 'register';
    tabRegister.classList.add('active');
    tabLogin.classList.remove('active');
    groupName.style.display = 'flex';
    groupPhone.style.display = 'flex';
    authSubmit.textContent = 'Register Partner';
    authSubtitle.textContent = 'Register a new Restaurant Partner account on GoFood.';
    document.getElementById('auth-name').setAttribute('required', 'true');
    document.getElementById('auth-phone').setAttribute('required', 'true');
  };

  authForm.onsubmit = async (e) => {
    e.preventDefault();
    
    const email = document.getElementById('auth-email').value;
    const password = document.getElementById('auth-password').value;

    try {
      if (state.activeTab === 'login') {
        const data = await fetchAPI('/auth/login', {
          method: 'POST',
          body: JSON.stringify({ email, password })
        });
        
        if (data.role === 'customer') {
          throw new Error('Customers do not have portal access. Please register a Partner account.');
        }

        saveAuthSession(data);
        showToast(`Welcome back, ${data.name}!`);
        swapView();
      } else {
        const name = document.getElementById('auth-name').value;
        const phone = document.getElementById('auth-phone').value;

        const data = await fetchAPI('/auth/register', {
          method: 'POST',
          body: JSON.stringify({
            name, email, phone, password, role: 'partner'
          })
        });

        saveAuthSession(data);
        showToast('Registration successful! Setup your restaurant now.');
        swapView();
      }
    } catch (err) {
      showToast(err.message, false);
    }
  };
}

function saveAuthSession(data) {
  state.token = data.token;
  state.role = data.role;
  state.user = { id: data.id, name: data.name, email: data.email, phone: data.phone };
  
  localStorage.setItem('gofood_token', data.token);
  localStorage.setItem('gofood_role', data.role);
  localStorage.setItem('gofood_user', JSON.stringify(state.user));
}

function logout() {
  localStorage.removeItem('gofood_token');
  localStorage.removeItem('gofood_role');
  localStorage.removeItem('gofood_user');
  state.token = null;
  state.role = null;
  state.user = null;
  state.restaurant = null;
  state.orders = [];
  state.foods = [];
  
  if (state.pollingInterval) {
    clearInterval(state.pollingInterval);
    state.pollingInterval = null;
  }

  showToast('Logged out successfully.');
  swapView();
}

// ==========================================
// PARTNER DASHBOARD WORKSPACE
// ==========================================

async function loadPartnerDashboard() {
  try {
    // Attempt to load restaurant profile linked to owner
    const restaurant = await fetchAPI('/restaurants/owner/me');
    state.restaurant = restaurant;
    
    // Hide onboarding panel if it was showing
    const onboardPanel = document.getElementById('partner-onboard-container');
    if (onboardPanel) onboardPanel.remove();

    // Show dashboards panels & metrics
    document.querySelector('.metrics-grid').style.display = 'grid';
    document.querySelector('.panel-layout').style.display = 'grid';

    // Populate outlet metrics details
    document.getElementById('metric-rating').textContent = parseFloat(restaurant.rating || 0).toFixed(1);
    
    // Set busy state toggle label
    updateOutletBusyToggleState(restaurant.is_busy);

    // Initial Load menu items and active orders
    await loadPartnerMenu();
    await loadPartnerOrders();

    // Set dynamic live order polling (every 5 seconds)
    state.pollingInterval = setInterval(loadPartnerOrders, 5000);

  } catch (err) {
    // If no restaurant, render an onboarding panel right inside the workspace
    if (err.message.includes('No restaurant registered')) {
      renderPartnerOnboardingPanel();
    } else {
      showToast(err.message, false);
    }
  }
}

function updateOutletBusyToggleState(isBusy) {
  const label = document.getElementById('outlet-status-label');
  const btn = document.getElementById('toggle-busy-btn');
  
  if (isBusy === 1 || isBusy === true) {
    label.textContent = 'Temporarily Busy';
    label.className = 'status-tag busy';
    btn.textContent = 'Set Accepting';
  } else {
    label.textContent = 'Accepting Orders';
    label.className = 'status-tag live';
    btn.textContent = 'Set Busy';
  }
}

// Onboard restaurant profile directly for logged in Partner (Dual Onboarding Flow)
function renderPartnerOnboardingPanel() {
  // Hide main dashboards metrics & layout grid
  document.querySelector('.metrics-grid').style.display = 'none';
  document.querySelector('.panel-layout').style.display = 'none';

  // Check if onboarding container is already there
  let onboardPanel = document.getElementById('partner-onboard-container');
  if (!onboardPanel) {
    onboardPanel = document.createElement('div');
    onboardPanel.id = 'partner-onboard-container';
    onboardPanel.className = 'restaurant-onboard-container';
    onboardPanel.innerHTML = `
      <div class="auth-card glass" style="max-width: 600px; margin: 40px auto; padding: 40px;">
        <div class="auth-header">
          <span style="font-size: 48px;">🏪</span>
          <h2>Register Your Restaurant</h2>
          <p style="margin-top: 8px;">Let's setup your outlet listing on GoFood to start receiving live orders!</p>
        </div>
        <form class="onboard-form" id="partner-restaurant-form" style="padding: 0; display: flex; flex-direction: column; gap: 20px;">
          <div class="form-row" style="display: flex; gap: 16px;">
            <div class="input-group" style="flex: 1;">
              <label for="p-rest-name">Restaurant Name</label>
              <input type="text" id="p-rest-name" required placeholder="Royal Biryani House">
            </div>
            <div class="input-group" style="flex: 1;">
              <label for="p-rest-cuisines">Cuisines (comma separated)</label>
              <input type="text" id="p-rest-cuisines" required placeholder="Biryani, North Indian">
            </div>
          </div>
          
          <div class="form-row" style="display: flex; gap: 16px;">
            <div class="input-group" style="flex: 1;">
              <label for="p-rest-image">Cover Photo Image URL</label>
              <input type="url" id="p-rest-image" required placeholder="https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600">
            </div>
            <div class="input-group" style="flex: 1;">
              <label for="p-rest-address">Detailed Address</label>
              <input type="text" id="p-rest-address" required placeholder="MG Road, Bangalore">
            </div>
          </div>
          
          <div class="form-row" style="display: flex; gap: 16px; margin-bottom: 12px;">
            <div class="input-group" style="flex: 1;">
              <label for="p-rest-distance">Simulated Distance (km)</label>
              <input type="number" step="0.1" id="p-rest-distance" required placeholder="2.5" value="1.5">
            </div>
            <div class="input-group" style="flex: 1;">
              <label for="p-rest-delivery">Delivery Fee (₹)</label>
              <input type="number" id="p-rest-delivery" required placeholder="40" value="40">
            </div>
          </div>
          
          <button type="submit" class="submit-btn" style="width: 100%; border-radius: 30px; padding: 14px;">Onboard My Outlet</button>
        </form>
      </div>
    `;

    document.getElementById('partner-workspace').appendChild(onboardPanel);
  }

  // Handle Partner onboarding submit
  document.getElementById('partner-restaurant-form').onsubmit = async (e) => {
    e.preventDefault();
    
    const name = document.getElementById('p-rest-name').value;
    const cuisine_type = document.getElementById('p-rest-cuisines').value;
    const image = document.getElementById('p-rest-image').value;
    const address = document.getElementById('p-rest-address').value;
    const distance = parseFloat(document.getElementById('p-rest-distance').value);
    const delivery_fee = parseFloat(document.getElementById('p-rest-delivery').value);

    try {
      await fetchAPI('/restaurants', {
        method: 'POST',
        body: JSON.stringify({
          name, cuisine_type, image, address, distance, delivery_fee
        })
      });

      showToast('Restaurant profile successfully created!');
      loadPartnerDashboard();
    } catch (err) {
      showToast(err.message, false);
    }
  };
}

// Outlet busy toggle action
document.getElementById('toggle-busy-btn').onclick = async () => {
  if (!state.restaurant) return;
  const newBusyState = state.restaurant.is_busy === 1 ? 0 : 1;
  
  try {
    await fetchAPI(`/restaurants/${state.restaurant.id}`, {
      method: 'PUT',
      body: JSON.stringify({ is_busy: newBusyState })
    });
    
    state.restaurant.is_busy = newBusyState;
    updateOutletBusyToggleState(newBusyState);
    showToast(`Outlet status successfully set to ${newBusyState ? 'Busy' : 'Accepting Orders'}.`);
  } catch (err) {
    showToast(err.message, false);
  }
};

// LOAD PARTNER FOOD MENU
async function loadPartnerMenu() {
  try {
    const foods = await fetchAPI(`/foods?restaurant_id=${state.restaurant.id}`);
    state.foods = foods;
    renderPartnerMenuGrid();
  } catch (err) {
    showToast(err.message, false);
  }
}

function renderPartnerMenuGrid() {
  const container = document.getElementById('dishes-grid-container');
  container.innerHTML = '';

  if (state.foods.length === 0) {
    container.innerHTML = `
      <div class="empty-state" style="grid-column: 1 / -1;">
        <span class="material-icons-round empty-icon">restaurant_menu</span>
        <h4>Menu is Empty</h4>
        <p>Start adding gorgeous dishes to showcase them on the mobile app.</p>
      </div>
    `;
    return;
  }

  state.foods.forEach(food => {
    const card = document.createElement('div');
    card.className = 'dish-card glass';
    card.innerHTML = `
      <div class="dish-image-wrapper">
        <img src="${food.image}" alt="${food.name}">
        <div class="dish-card-badges">
          <span class="dish-badge ${food.is_veg ? 'veg' : 'nonveg'}">${food.is_veg ? 'VEG' : 'NON-VEG'}</span>
          ${food.is_popular ? '<span class="dish-badge popular">Popular</span>' : ''}
        </div>
      </div>
      
      <div class="dish-card-info">
        <div class="dish-header-row">
          <div>
            <h4 class="dish-title" title="${food.name}">${food.name}</h4>
            <span class="dish-category-label">${food.category || 'Dishes'}</span>
          </div>
          <div class="food-type-icon ${food.is_veg ? '' : 'non-veg'}" title="${food.is_veg ? 'Vegetarian' : 'Non-Vegetarian'}"></div>
        </div>
        
        <p class="dish-description" title="${food.description || 'No description provided.'}">${food.description || 'No description provided.'}</p>
        
        <div class="dish-footer-row">
          <span class="dish-price-tag">₹${parseFloat(food.price).toFixed(2)}</span>
          <div class="dish-actions">
            <button class="dish-action-icon-btn edit-dish-trigger" data-id="${food.id}" title="Edit Dish">
              <span class="material-icons-round">edit</span>
            </button>
            <button class="dish-action-icon-btn delete delete-dish-trigger" data-id="${food.id}" title="Delete Dish">
              <span class="material-icons-round">delete</span>
            </button>
          </div>
        </div>
      </div>
    `;
    container.appendChild(card);
  });

  // Attach event listeners to CRUD actions
  container.querySelectorAll('.edit-dish-trigger').forEach(btn => {
    btn.onclick = () => openDishFormModal(parseInt(btn.getAttribute('data-id')));
  });

  container.querySelectorAll('.delete-dish-trigger').forEach(btn => {
    btn.onclick = () => deleteDishItem(parseInt(btn.getAttribute('data-id')));
  });
}

// LOAD PARTNER DYNAMIC ACTIVE ORDERS
async function loadPartnerOrders() {
  try {
    const orders = await fetchAPI(`/orders/restaurant/${state.restaurant.id}`);
    
    // Sort orders: keep pending/preparing active at top, delivered at bottom
    orders.sort((a, b) => {
      const activeStates = ['pending', 'accepted', 'preparing', 'outForDelivery'];
      const aActive = activeStates.includes(a.status);
      const bActive = activeStates.includes(b.status);
      if (aActive && !bActive) return -1;
      if (!aActive && bActive) return 1;
      return new Date(b.created_at) - new Date(a.created_at);
    });

    state.orders = orders;
    renderPartnerOrdersList();
    calculateRevenueMetrics();
  } catch (err) {
    // If polling fails, clear interval to prevent endless alerts
    if (state.pollingInterval) clearInterval(state.pollingInterval);
    showToast(err.message, false);
  }
}

function calculateRevenueMetrics() {
  let completedCount = 0;
  let revenueTotal = 0;

  state.orders.forEach(order => {
    if (order.status === 'delivered') {
      completedCount++;
      // Sum items that are from this specific restaurant to get exact shop revenue
      order.items.forEach(item => {
        revenueTotal += parseFloat(item.total_price);
      });
    }
  });

  document.getElementById('metric-orders').textContent = completedCount;
  document.getElementById('metric-revenue').textContent = `₹${revenueTotal.toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
}

function renderPartnerOrdersList() {
  const container = document.getElementById('orders-list-container');
  
  // Exclude fully delivered orders from top "Live" processing list to keep it decluttered
  const activeOrders = state.orders.filter(o => o.status !== 'delivered');

  if (activeOrders.length === 0) {
    container.innerHTML = `
      <div class="empty-state">
        <span class="material-icons-round empty-icon">receipt_long</span>
        <h4>No Active Orders</h4>
        <p>Live incoming customer orders will appear here dynamically.</p>
      </div>
    `;
    return;
  }

  // Preserve scroll position if user is reading
  const scrollPos = container.scrollTop;
  container.innerHTML = '';

  activeOrders.forEach(order => {
    const card = document.createElement('div');
    card.className = 'order-card';
    
    // Format timestamp nicely
    const orderTime = new Date(order.created_at).toLocaleTimeString('en-US', {
      hour: '2-digit', minute: '2-digit'
    });

    // Build items HTML list
    const itemsHTML = order.items.map(item => `
      <div class="order-item-row">
        <div class="order-item-name-qty">
          <span class="order-item-qty">x${item.quantity}</span>
          <span>${item.food_name}</span>
        </div>
        <span class="order-item-price">₹${parseFloat(item.total_price).toFixed(2)}</span>
      </div>
    `).join('');

    // Calculate restaurant specific order total
    const subtotal = order.items.reduce((acc, it) => acc + parseFloat(it.total_price), 0);

    // Get order status label & progress button
    let statusText = 'Pending Approval';
    let nextStatus = 'accepted';
    let btnText = 'Accept Order';
    let hideBtn = false;

    if (order.status === 'accepted') {
      statusText = 'Preparing Food';
      nextStatus = 'preparing';
      btnText = 'Start Preparing';
    } else if (order.status === 'preparing') {
      statusText = 'Awaiting Pickup';
      nextStatus = 'outForDelivery';
      btnText = 'Handover / Out';
    } else if (order.status === 'outForDelivery') {
      statusText = 'Out for Delivery';
      nextStatus = 'delivered';
      btnText = 'Mark Delivered';
    } else if (order.status === 'delivered') {
      statusText = 'Completed';
      hideBtn = true;
    }

    card.innerHTML = `
      <div class="order-card-header">
        <span class="order-id-badge">${order.id} <span style="font-size: 11px; font-weight: normal; color: var(--text-muted); margin-left: 8px;">at ${orderTime}</span></span>
        <span class="order-status-badge ${order.status}">${statusText}</span>
      </div>
      
      <div class="order-card-body">
        <div class="order-customer-info">
          <span class="order-cust-name">${order.customer_name}</span>
          <span class="order-cust-phone"><span class="material-icons-round">phone</span> ${order.customer_phone}</span>
          <span class="order-cust-address"><span class="material-icons-round">location_on</span> ${order.delivery_address}</span>
        </div>
        
        <div class="order-items-summary">
          ${itemsHTML}
        </div>
      </div>
      
      <div class="order-card-footer">
        <div class="order-total-block">
          <span class="order-total-label">Subtotal</span>
          <span class="order-total-val">₹${subtotal.toFixed(2)}</span>
        </div>
        
        ${!hideBtn ? `
          <button class="order-btn status-transition-btn" data-id="${order.id}" data-next="${nextStatus}">
            ${btnText}
          </button>
        ` : ''}
      </div>
    `;

    container.appendChild(card);
  });

  // Keep scroll position
  container.scrollTop = scrollPos;

  // Add event listener to transition status
  container.querySelectorAll('.status-transition-btn').forEach(btn => {
    btn.onclick = async () => {
      const orderId = btn.getAttribute('data-id');
      const nextStatus = btn.getAttribute('data-next');
      await updateOrderStatus(orderId, nextStatus);
    };
  });
}

async function updateOrderStatus(orderId, status) {
  try {
    await fetchAPI(`/orders/${orderId}/status`, {
      method: 'PUT',
      body: JSON.stringify({ status })
    });
    
    showToast(`Order ${orderId} successfully set to ${status}.`);
    
    // Instantly refresh orders
    await loadPartnerOrders();
  } catch (err) {
    showToast(err.message, false);
  }
}

// MENU DISH CRUD POPUPS & MODALS
const dishModal = document.getElementById('dish-modal');
const closeDishModal = document.getElementById('close-dish-modal');
const cancelDishForm = document.getElementById('cancel-dish-form');
const dishForm = document.getElementById('dish-form');

document.getElementById('open-add-dish-modal').onclick = () => {
  openDishFormModal();
};

closeDishModal.onclick = () => dishModal.classList.add('hidden');
cancelDishForm.onclick = () => dishModal.classList.add('hidden');

// Close modal if clicked outside
window.onclick = (e) => {
  if (e.target === dishModal) {
    dishModal.classList.add('hidden');
  }
};

function openDishFormModal(foodId = null) {
  const title = document.getElementById('dish-modal-title');
  dishForm.reset();
  
  if (foodId) {
    title.textContent = 'Edit Food Item';
    const dish = state.foods.find(f => f.id === foodId);
    if (!dish) return;

    document.getElementById('dish-id').value = dish.id;
    document.getElementById('dish-name').value = dish.name;
    document.getElementById('dish-category').value = dish.category || '';
    document.getElementById('dish-price').value = parseInt(dish.price);
    document.getElementById('dish-veg').checked = dish.is_veg === 1 || dish.is_veg === true;
    document.getElementById('dish-image').value = dish.image;
    document.getElementById('dish-desc').value = dish.description || '';
  } else {
    title.textContent = 'Add New Food Dish';
    document.getElementById('dish-id').value = '';
    document.getElementById('dish-veg').checked = true; // vegetarian default
  }

  dishModal.classList.remove('hidden');
}

dishForm.onsubmit = async (e) => {
  e.preventDefault();
  
  const id = document.getElementById('dish-id').value;
  const name = document.getElementById('dish-name').value;
  const category = document.getElementById('dish-category').value;
  const price = parseFloat(document.getElementById('dish-price').value);
  const is_veg = document.getElementById('dish-veg').checked;
  const image = document.getElementById('dish-image').value;
  const description = document.getElementById('dish-desc').value;

  const payload = {
    name, category, price, is_veg, image, description,
    restaurant_id: state.restaurant.id
  };

  try {
    if (id) {
      // Edit mode
      await fetchAPI(`/foods/${id}`, {
        method: 'PUT',
        body: JSON.stringify(payload)
      });
      showToast('Dish item updated successfully!');
    } else {
      // Add mode
      await fetchAPI('/foods', {
        method: 'POST',
        body: JSON.stringify(payload)
      });
      showToast('New dish successfully added to menu catalog!');
    }

    dishModal.classList.add('hidden');
    await loadPartnerMenu();
  } catch (err) {
    showToast(err.message, false);
  }
};

async function deleteDishItem(foodId) {
  if (!confirm('Are you sure you want to delete this food item from your menu catalog?')) return;
  
  try {
    await fetchAPI(`/foods/${foodId}`, {
      method: 'DELETE'
    });
    
    showToast('Menu item deleted successfully.');
    await loadPartnerMenu();
  } catch (err) {
    showToast(err.message, false);
  }
}

// ==========================================
// ADMIN DASHBOARD WORKSPACE
// ==========================================

async function loadAdminDashboard() {
  try {
    // 1. Fetch all partner accounts to populate onboarding owner select dropdown
    const partners = await fetchAPI('/auth/partners');
    state.partners = partners;
    populateAdminPartnersDropdown();

    // 2. Fetch all restaurants
    const restaurants = await fetchAPI('/restaurants');
    state.restaurants = restaurants; // Store in local state for active search
    
    // Set admin metrics values
    document.getElementById('admin-metric-rests').textContent = restaurants.length;
    document.getElementById('admin-metric-partners').textContent = partners.length;

    renderAdminOutletDirectory(restaurants);
  } catch (err) {
    showToast(err.message, false);
  }
}

function populateAdminPartnersDropdown() {
  const select = document.getElementById('rest-owner-select');
  select.innerHTML = '<option value="">-- Choose Partner Account --</option>';
  
  state.partners.forEach(partner => {
    const opt = document.createElement('option');
    opt.value = partner.id;
    opt.textContent = `${partner.name} (${partner.email})`;
    select.appendChild(opt);
  });
}

function renderAdminOutletDirectory(restaurants) {
  const tbody = document.getElementById('listings-table-body');
  tbody.innerHTML = '';

  if (restaurants.length === 0) {
    tbody.innerHTML = `
      <tr>
        <td colspan="6" style="text-align: center; padding: 40px; color: var(--text-muted);">
          No outlets matched your search or registered yet.
        </td>
      </tr>
    `;
    return;
  }

  restaurants.forEach(rest => {
    const row = document.createElement('tr');
    
    const ownerName = rest.owner_id 
      ? (state.partners.find(p => p.id === rest.owner_id)?.name || `Owner (ID: ${rest.owner_id})`)
      : 'Unassigned';

    row.innerHTML = `
      <td><strong>#${rest.id}</strong></td>
      <td><img src="${rest.image}" class="table-image" alt="${rest.name}"></td>
      <td>
        <span class="table-restaurant-name">${rest.name}</span>
        <div style="font-size: 11px; color: var(--text-muted);">Owner: ${ownerName}</div>
      </td>
      <td>${rest.cuisine_type}</td>
      <td>
        <span class="table-rating-badge">
          <span class="material-icons-round">star</span> ${parseFloat(rest.rating || 0).toFixed(1)}
        </span>
      </td>
      <td>
        <div class="table-action-group">
          <button class="dish-action-icon-btn edit-rest-trigger" data-id="${rest.id}" title="Edit Restaurant Details">
            <span class="material-icons-round">edit</span>
          </button>
          <button class="dish-action-icon-btn delete delete-rest-trigger" data-id="${rest.id}" title="Delete Restaurant Profile">
            <span class="material-icons-round">delete</span>
          </button>
        </div>
      </td>
    `;
    tbody.appendChild(row);
  });

  tbody.querySelectorAll('.edit-rest-trigger').forEach(btn => {
    btn.onclick = () => openRestEditModal(parseInt(btn.getAttribute('data-id')));
  });

  tbody.querySelectorAll('.delete-rest-trigger').forEach(btn => {
    btn.onclick = () => deleteRestaurantProfile(parseInt(btn.getAttribute('data-id')));
  });
}

// ADMIN ONBOARD OUTLET SUBMIT
document.getElementById('onboard-restaurant-form').onsubmit = async (e) => {
  e.preventDefault();
  
  const name = document.getElementById('rest-name').value;
  const cuisine_type = document.getElementById('rest-cuisines').value;
  const image = document.getElementById('rest-image').value;
  const address = document.getElementById('rest-address').value;
  const distance = parseFloat(document.getElementById('rest-distance').value);
  const delivery_fee = parseFloat(document.getElementById('rest-delivery').value);
  const owner_id = parseInt(document.getElementById('rest-owner-select').value);

  try {
    await fetchAPI('/restaurants', {
      method: 'POST',
      body: JSON.stringify({
        name, cuisine_type, image, address, distance, delivery_fee, owner_id
      })
    });

    showToast('New outlet profile onboarded successfully!');
    document.getElementById('onboard-restaurant-form').reset();
    await loadAdminDashboard();
  } catch (err) {
    showToast(err.message, false);
  }
};

async function deleteRestaurantProfile(restaurantId) {
  if (!confirm('CRITICAL WARNING: Deleting this restaurant profile will permanently remove all associated food dishes, addons, reviews, and dashboard history. This action CANNOT be undone. Are you sure you want to proceed?')) return;
  
  try {
    await fetchAPI(`/restaurants/${restaurantId}`, {
      method: 'DELETE'
    });

    showToast('Restaurant profile deleted successfully.');
    await loadAdminDashboard();
  } catch (err) {
    showToast(err.message, false);
  }
}

// ADMIN RESTAURANT EDITING MODAL HANDLERS
const restModal = document.getElementById('rest-modal');
const closeRestModal = document.getElementById('close-rest-modal');
const cancelRestForm = document.getElementById('cancel-rest-form');
const restEditForm = document.getElementById('rest-edit-form');

closeRestModal.onclick = () => restModal.classList.add('hidden');
cancelRestForm.onclick = () => restModal.classList.add('hidden');

function openRestEditModal(restaurantId) {
  const rest = state.restaurants.find(r => r.id === restaurantId);
  if (!rest) return;

  document.getElementById('edit-rest-id').value = rest.id;
  document.getElementById('edit-rest-name').value = rest.name;
  document.getElementById('edit-rest-cuisines').value = rest.cuisine_type;
  document.getElementById('edit-rest-image').value = rest.image;
  document.getElementById('edit-rest-address').value = rest.address || '';
  document.getElementById('edit-rest-distance').value = rest.distance || 1.0;
  document.getElementById('edit-rest-delivery').value = parseInt(rest.delivery_fee || 40);
  document.getElementById('edit-rest-busy').checked = rest.is_busy === 1 || rest.is_busy === true;

  // Populate edit owner dropdown options
  const select = document.getElementById('edit-rest-owner-select');
  select.innerHTML = '<option value="">-- Choose Partner Account --</option>';
  state.partners.forEach(partner => {
    const opt = document.createElement('option');
    opt.value = partner.id;
    opt.textContent = `${partner.name} (${partner.email})`;
    select.appendChild(opt);
  });
  select.value = rest.owner_id || '';

  restModal.classList.remove('hidden');
}

restEditForm.onsubmit = async (e) => {
  e.preventDefault();
  
  const id = document.getElementById('edit-rest-id').value;
  const name = document.getElementById('edit-rest-name').value;
  const cuisine_type = document.getElementById('edit-rest-cuisines').value;
  const image = document.getElementById('edit-rest-image').value;
  const address = document.getElementById('edit-rest-address').value;
  const distance = parseFloat(document.getElementById('edit-rest-distance').value);
  const delivery_fee = parseFloat(document.getElementById('edit-rest-delivery').value);
  const owner_id = parseInt(document.getElementById('edit-rest-owner-select').value) || null;
  const is_busy = document.getElementById('edit-rest-busy').checked ? 1 : 0;

  try {
    await fetchAPI(`/restaurants/${id}`, {
      method: 'PUT',
      body: JSON.stringify({
        name, cuisine_type, image, address, distance, delivery_fee, owner_id, is_busy
      })
    });

    showToast('Restaurant updated successfully!');
    restModal.classList.add('hidden');
    await loadAdminDashboard();
  } catch (err) {
    showToast(err.message, false);
  }
};

// ==========================================
// INITIAL SETUP
// ==========================================

// Global click outside to dismiss modals
window.addEventListener('click', (e) => {
  if (e.target === dishModal) {
    dishModal.classList.add('hidden');
  }
  if (e.target === restModal) {
    restModal.classList.add('hidden');
  }
});

// Admin live search filter input trigger
document.getElementById('admin-search-input').oninput = (e) => {
  const q = e.target.value.toLowerCase().trim();
  if (!state.restaurants) return;
  const filtered = state.restaurants.filter(r => 
    r.name.toLowerCase().includes(q) || 
    r.cuisine_type.toLowerCase().includes(q)
  );
  renderAdminOutletDirectory(filtered);
};

// Attach logout handler
document.getElementById('logout-trigger').onclick = logout;

// Initial View Trigger
swapView();
