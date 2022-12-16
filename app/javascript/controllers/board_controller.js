import { Controller } from "@hotwired/stimulus";
import axios from  "axios";
import { get, map, sample } from "lodash-es";

export default class extends Controller {
    HEADERS = { "ACCEPT": "application/json" };  
    BACKGROUND_COLORS = ["bg-red-500", "bg-rose-500", "bg-pink-500", "bg-fuchsia-500", "bg-purple-500", "bg-violet-500", "bg-indigo-500", "bg-cyan-500", "bg-teal-500", "bg-emerald-500", "bg-lime-500", "bg-amber-500", "bg-orange-500", "bg-blue-500", "bg-green-500", "bg-sky-500", "bg-slate-500", "bg-yellow-500"];

    connect() {
        document.getElementById("tarefas").innerHTML = null;
        axios.get(this.element.dataset.apiUrl, { headers: this.HEADERS }).then((resposta) => {
            this.buildKanban(this.buildTarefas(resposta["data"]));
            this.cursorPointerToHeaderTitle();
            this.addLinkToHeaderTitle(this.buildTarefas(resposta["data"]));
            this.addHeaderDeleteButton(this.buildTarefas(resposta["data"]));
        });    
    }

    getHeaders(){
        return Array.from(document.getElementsByClassName("kanban-board-header"));
    }

    getHeaderTitle(){
        return Array.from(document.getElementsByClassName("kanban-title-board"));
    }

    cursorPointerToHeaderTitle(){
        this.getHeaderTitle().forEach((headerTitle) => {
            headerTitle.classList.add("cursor-pointer");
        });  
    }

    addLinkToHeaderTitle(tarefas){
        this.getHeaderTitle().forEach((headerTitle, index) => {
            headerTitle.addEventListener(("click"), () => {
                Turbo.visit(`${this.element.dataset.boardListsUrl}/${tarefas[index].id}/edit`);
            });
        });
    }

    buildDeleteButton(boardId){
        const button = document.createElement("button");
        button.classList.add("kanban-title-button");
        button.classList.add("btn");
        button.classList.add("btn-default");
        button.classList.add("btn-xs");
        button.classList.add("text-base");
        button.classList.add("mr-3");
        button.classList.add("text-base");
        button.classList.add("bg-white");
        button.classList.add("text-black");
        button.classList.add("hover:bg-red-500");
        button.classList.add("font-bold");
        button.classList.add("hover:border-white");
        button.classList.add("border-2");
        button.classList.add("border-transparent");
        button.classList.add("hover:text-white");
        button.classList.add("px-0.5"); 
        button.classList.add("rounded-lg");
        button.classList.add("items-center");
        button.textContent = "x";

        button.addEventListener("click", (e) => {
            e.preventDefault();
            console.log("buton with id: ", boardId);

            axios.delete(`${this.element.dataset.boardListsUrl}/${boardId}`, {
                headers: this.HEADERS
            }).then(() => {
                Turbo.visit(window.location.href);
            });
        });
        return button;
    }

    addHeaderDeleteButton(boards){       
        this.getHeaders().forEach((header, index) => {
            header.appendChild(this.buildDeleteButton(boards[index].id));
        });
    }

    buildClassList(){
        return `text-white, ${sample(this.BACKGROUND_COLORS)}`;
        
    }

    buildItems(items){
        return map(items, (item) => {
            return {
                "id": get(item, "id"),
                "title": get(item, "attributes.title"),
                "class": this.buildClassList(),
                "list-id": get(item, "attributes.list_id"),
            }
        });
    }

    buildTarefas(tarefasData){
        return map(tarefasData["data"], (tarefa) => {
            return {
                "id": get(tarefa, "id"),
                "title": get(tarefa, "attributes.title"),
                "class": this.buildClassList(),
                "item": this.buildItems(get(tarefa, "attributes.items.data"))
            }
        });
    }

    updateListPosition(el){
        axios.put(`${this.element.dataset.listPositionsApiUrl}/${el.dataset.id}`,
        {
            position: el.dataset.order - 1
        }, 
        {
            headers: this.HEADERS
        }).then((response) => {
            console.log("Resposta: ", response);
        });
    }

    buildItemsData(items){
        return map(items, (item) => {
            return {
                id: item.dataset.eid,
                position: item.dataset.position,
                list_id: item.dataset.listId
            }
        });
    }

    itemPositionsApiUrlCall(itemsData){
        axios.put(this.element.dataset.itemPositionsApiUrl, {
            items: itemsData
        }, {
            headers: this.HEADERS
        }).then(() => {

        }); 
    }
    
    updateItemPosition(target, source){
        const targetItems = Array.from(target.getElementsByClassName("kanban-item"));

        targetItems.forEach((item, index) => {
            item.dataset.position = index;
            item.dataset.listId = target.closest(".kanban-board").dataset.id;
        });
        this.itemPositionsApiUrlCall(this.buildItemsData(targetItems));
    }

    showItemModal(){
        document.getElementById("show-modal-div").click();
    }

    populateItemInformation(itemId){
        axios.get(`/api/items/${itemId}`, {}, {
            header: this.HEADERS
        }).then((response) => {
            document.getElementById("item-title").textContent = get(response, "data.data.attributes.title");
            document.getElementById("item-description").textContent = get(response, "data.data.attributes.description");
            document.getElementById("item-edit-link").href = `/lists/${get(response, 'data.data.attributes.list_id')}/items/${itemId}/edit`;
            document.getElementById("item-assagin-member-link").href = `/items/${get(response, "data.data.id")}/item_members/new`;
            const membersList = map (get(response, "data.data.attributes.members.data"), (member) => {
                const listItem = document.createElement("li");
                listItem.classList.add("border-b");
                listItem.classList.add("border-gray-200");
                listItem.classList.add("py-1");
                listItem.classList.add("text-base");
                listItem.textContent = member.attributes.email;
                return listItem;
            });
            document.getElementById("item-members-list").innerHTML = null;
            membersList.forEach((member) => {
                document.getElementById("item-members-list").appendChild(member);
            });
            document.getElementById("item-delete-link").addEventListener("click", (e) => {
                e.preventDefault();
                axios.delete(`/lists/${get(response, 'data.data.attributes.list_id')}/items/${itemId}/`, {
                    headers: this.HEADERS
                }).then(() => {
                    Turbo.visit(window.location.href); 
                });
            });
        });        
    }

    buildKanban(tarefas){
        document.getElementById("tarefas").innerHTML = null;
        new jKanban({
            element: `#${this.element.id}`,
            boards: tarefas,
            itemAddOptions:{
                enabled: true,
                content: "+",
                class: "kanban-title-button btn btn-default btn-xs text-base bg-white text-black hover:bg-sky-500 font-bold hover:border-white border-2 border-transparent hover:text-white px-0.5 rounded-lg items-center",
            },
            click: (el) => {
                this.showItemModal();
                this.populateItemInformation(el.dataset.eid);
            },
            buttonClick: (el, boardId) => {
                Turbo.visit(`/lists/${boardId}/items/new`);
            },
            dragendBoard: (el) => {
                this.updateListPosition(el);
            },
            dropEl: (el, target, source, sibling) => {
                this.updateItemPosition(target);
            }
        });
    }
}
